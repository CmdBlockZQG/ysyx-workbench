#include <common.h>
#include <elf.h>

#ifdef CONFIG_ISA64
#define ElfN(type) Elf64_ ## type
#else
#define ElfN(type) Elf32_ ## type
#endif

#ifndef CONFIG_TARGET_AM
static FILE *fp = NULL;

static ElfN(Ehdr) eh;

#define STRTAB_BUF_SIZE 2048
#define MAX_SYMBOL 256

static char strtab_buf[STRTAB_BUF_SIZE];
static char *elf_no_name = "<anonymous symbol>";
ElfSymbol elf_symbol_list[MAX_SYMBOL];
word_t elf_symbol_list_size = 0;

void init_elf(const char *elf_file) {
  if (elf_file == NULL) return;
  fp = fopen(elf_file, "rb");
  Assert(fp, "Can not open '%s'", elf_file);

  /* Read elf header */
  Assert(fread(&eh, sizeof(eh), 1, fp) == 1, "Error when reading elf header");

  Assert(eh.e_ident[EI_MAG0] == ELFMAG0 &&
         eh.e_ident[EI_MAG1] == ELFMAG1 &&
         eh.e_ident[EI_MAG2] == ELFMAG2 &&
         eh.e_ident[EI_MAG3] == ELFMAG3, 
         "Invalid elf file '%s'", elf_file);
  
  Assert(eh.e_ident[EI_CLASS] == MUXDEF(CONFIG_ISA64, ELFCLASS64, ELFCLASS32),
         "Elf file architecture(32/64-bit) incompatible.");
  
  Assert(eh.e_shoff, "Elf file has no section header.");

  void read_symbols();
  read_symbols();
}

/* Read section header string table, find ".strtab"'s index in it */
size_t read_strtab_name_ndx() {
  ElfN(Shdr) shstrent;
  fseek(fp, eh.e_shoff + eh.e_shstrndx * eh.e_shentsize, SEEK_SET);
  Assert(fread(&shstrent, sizeof(shstrent), 1, fp) == 1,
         "Error when reading section header string table entry");
  Assert(shstrent.sh_type == SHT_STRTAB, "Reading wrong section header string table entry");
  char shstrbuf[shstrent.sh_size];
  fseek(fp, shstrent.sh_offset, SEEK_SET);
  Assert(fread(shstrbuf, shstrent.sh_size, 1, fp) == 1,
         "Error when reading section header string table buffer");
  size_t strtab_name_ndx = 0;
  for (size_t i = 1; i < shstrent.sh_size; ++i) {
    if (shstrbuf[i] && !shstrbuf[i - 1]) {
      if (!strcmp(&shstrbuf[i], ".strtab")) break;
      ++strtab_name_ndx;
    }
  }
  return strtab_name_ndx;
}

void read_symbols() {
  size_t strtab_name_ndx = read_strtab_name_ndx();
  
  ElfN(Shdr) shent, strtab_ent = { .sh_offset = 0 }, symtab_ent = { .sh_offset = 0 };

  fseek(fp, eh.e_shoff, SEEK_SET);
  Assert(fread(&shent, sizeof(shent), 1, fp) == 1, "Error when reading section table entry 0");
  size_t shnum = eh.e_shnum ? eh.e_shnum : shent.sh_size;

  for (size_t i = 1; i < shnum; ++i) {
    fseek(fp, eh.e_shoff + i * eh.e_shentsize, SEEK_SET);
    Assert(fread(&shent, sizeof(shent), 1, fp) == 1, "Error when reading section table entry %lu", i);
    printf("%lu %u %u %u %u %u\n", i, shent.sh_name, shent.sh_type, shent.sh_addr, shent.sh_offset, shent.sh_size);
    if (shent.sh_type == SHT_STRTAB && shent.sh_name == strtab_name_ndx) { // find .strtab entry
      strtab_ent = shent;
    } else if (shent.sh_type == SHT_SYMTAB) { // find .symtab entry
      symtab_ent = shent;
    }
  }

  Assert(strtab_ent.sh_offset, "No .strtab section in elf file");
  Assert(symtab_ent.sh_offset, "No .symtab section in elf file");

  // unpack string table
  fseek(fp, strtab_ent.sh_offset, SEEK_SET);
  Assert(fread(strtab_buf, strtab_ent.sh_size, 1, fp) == 1,
         "Error when reading symbol string table buffer");
  char *strtab[MAX_SYMBOL];
  size_t strtab_size = 0;
  for (size_t i = 1; i < strtab_ent.sh_size; ++i) {
    if (strtab_buf[i] && !strtab_buf[i - 1]) {
      strtab[strtab_size++] = &strtab_buf[i];
    }
  }
  
  // reorgnize symbols
  size_t symtab_size = symtab_ent.sh_size / symtab_ent.sh_entsize;
  Assert(symtab_ent.sh_entsize == sizeof(ElfN(Sym)), "Incompatible size of symbol table entry");
  ElfN(Sym) symtab[symtab_size];
  fseek(fp, symtab_ent.sh_offset, SEEK_SET);
  Assert(fread(symtab, symtab_ent.sh_entsize, symtab_size, fp) == symtab_size, "Error when reading symbol table");
  for (size_t i = 0; i < symtab_size; ++i) {
    if (symtab[i].st_info == STT_FUNC) {
      elf_symbol_list[elf_symbol_list_size++] = (ElfSymbol) {
        symtab[i].st_name ? strtab[symtab[i].st_name] : elf_no_name, // name
        symtab[i].st_value, // addr
        symtab[i].st_size, // size
        ELF_SYM_FUNC
      };
    } else if (symtab[i].st_info == STT_OBJECT) {
      elf_symbol_list[elf_symbol_list_size++] = (ElfSymbol) {
        symtab[i].st_name ? strtab[symtab[i].st_name] : elf_no_name, // name
        symtab[i].st_value, // addr
        symtab[i].st_size, // size
        ELF_SYM_OBJECT
      };
    }
  }

  for (word_t i = 0; i < elf_symbol_list_size; ++i) {
    printf("%s %u %u %s\n",
      elf_symbol_list[i].name,
      elf_symbol_list[i].addr,
      elf_symbol_list[i].size,
      elf_symbol_list[i].type == ELF_SYM_FUNC ? "FUNC" : "OBJECT"
    );
  }
}

#endif