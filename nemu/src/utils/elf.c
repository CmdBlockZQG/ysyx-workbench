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

void init_elf(const char *elf_file) {
  if (elf_file == NULL) return;
  fp = fopen(elf_file, "rb");
  Assert(fp, "Can not open '%s'", elf_file);

  /* Read elf header */
  Assert(fread(&eh, sizeof(eh), 1, fp) == sizeof(eh), "Error when reading elf header");

  Assert(eh.e_ident[EI_MAG0] == ELFMAG0 &&
         eh.e_ident[EI_MAG1] == ELFMAG1 &&
         eh.e_ident[EI_MAG2] == ELFMAG2 &&
         eh.e_ident[EI_MAG3] == ELFMAG3, 
         "Invalid elf file '%s'", elf_file);
  
  Assert(eh.e_ident[EI_CLASS] == MUXDEF(CONFIG_ISA64, ELFCLASS64, ELFCLASS32),
         "Elf file architecture(32/64-bit) incompatible.");
  
  Assert(eh.e_shoff, "Elf file has no section header.");

  /* Read section header string table */
  ElfN(Shdr) shstrent;
  fseek(fp, eh.e_shoff + eh.e_shstrndx * eh.e_shentsize, SEEK_SET);
  Assert(fread(&shstrent, sizeof(shstrent), 1, fp) == sizeof(shstrent),
         "Error when reading section header string table entry");
  Assert(shstrent.sh_type == SHT_STRTAB, "Reading wrong section header string table entry");
  char shstrbuf[shstrent.sh_size];
  fseek(fp, shstrent.sh_offset, SEEK_SET);
  Assert(fread(shstrbuf, shstrent.sh_size, 1, fp) == shstrent.sh_size,
         "Error when reading section header string table buffer");
  size_t strtab_ndx = 0;
  for (size_t i = 1; i < shstrent.sh_size; ++i) {
    if (shstrbuf[i] && !shstrbuf[i - 1]) {
      if (!strcmp(&shstrbuf[i], ".strtab")) break;
      ++strtab_ndx;
    }
  }

  printf("[ELF_HEADER_DEBUG] %lu\n", strtab_ndx);

  /* Read section header */
  // ElfN(Shdr) sh;
  // fseek(fp, eh.e_shoff, SEEK_SET);
  // fread(&sh, sizeof(sh), 1, fp);
  // size_t shnum = eh.e_shnum ? eh.e_shnum : sh.sh_size;
  
  // fread(&sh, sizeof(sh), 1, fp);
}
#endif