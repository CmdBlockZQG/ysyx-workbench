#include <proc.h>
#include <elf.h>
#include <ramdisk.h>

#ifdef __LP64__
# define Elf_Ehdr Elf64_Ehdr
# define Elf_Phdr Elf64_Phdr
# define Elf_Shdr Elf64_Shdr
#else
# define Elf_Ehdr Elf32_Ehdr
# define Elf_Phdr Elf32_Phdr
# define Elf_Shdr Elf32_Shdr
#endif

#if defined(__ISA_NATIVE__)
#define EXPECT_EM EM_X86_64
#elif defined(__ISA_RISCV32__)
#define EXPECT_EM EM_RISCV
#endif

static uintptr_t loader(PCB *pcb, const char *filename) {
  // read ELF header
  Elf_Ehdr ehdr;
  ramdisk_read(&ehdr, 0, sizeof(ehdr));

  // check magic number
  assert(ehdr.e_ident[EI_MAG0] == ELFMAG0 &&
         ehdr.e_ident[EI_MAG1] == ELFMAG1 &&
         ehdr.e_ident[EI_MAG2] == ELFMAG2 &&
         ehdr.e_ident[EI_MAG3] == ELFMAG3);

  // check 32/64 
#ifdef __LP64__
  assert(ehdr.e_ident[EI_CLASS] == ELFCLASS64);
#else
  assert(ehdr.e_ident[EI_CLASS] == ELFCLASS32);
#endif

  // check ISA
  assert(ehdr.e_machine == EXPECT_EM);

  // read program header
  size_t phoff = ehdr.e_phoff;
  assert(phoff);
  size_t phentsize = ehdr.e_phentsize;

  size_t phnum = ehdr.e_phnum;
  if (phnum == PN_XNUM) {
    Elf_Shdr shdr;
    assert(ehdr.e_shoff);
    ramdisk_read(&shdr, ehdr.e_shoff, sizeof(shdr));
    phnum = shdr.sh_info;
  }
  assert(phnum);

  Elf_Phdr phdr;
  for (size_t i = 0; i < phnum; ++i) {
    ramdisk_read(&phdr, phoff + i * phentsize, sizeof(phdr));
    if (phdr.p_vaddr == 0) continue;
    ramdisk_read((void *)phdr.p_vaddr, phdr.p_offset, phdr.p_filesz);
    memset((void *)(phdr.p_vaddr + phdr.p_filesz), 0, phdr.p_memsz - phdr.p_filesz);
  }

  return 0;
}

void naive_uload(PCB *pcb, const char *filename) {
  uintptr_t entry = loader(pcb, filename);
  Log("Jump to entry = %p", entry);
  ((void(*)())entry) ();
}

