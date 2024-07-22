#include <proc.h>
#include <elf.h>
#include <ramdisk.h>
#include <fs.h>

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
  // open file
  int fd = fs_open(filename, 0, 0);

  // read ELF header
  Elf_Ehdr ehdr;
  assert(fs_read(fd, &ehdr, sizeof(ehdr)) == sizeof(ehdr));

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
    fs_lseek(fd, ehdr.e_shoff, SEEK_SET);
    assert(fs_read(fd, &shdr, sizeof(shdr)) == sizeof(shdr));
    phnum = shdr.sh_info;
  }
  assert(phnum);

  Elf_Phdr phdr;
  for (size_t i = 0; i < phnum; ++i) {
    fs_lseek(fd, phoff + i * phentsize, SEEK_SET);
    assert(fs_read(fd, &phdr, sizeof(phdr)) == sizeof(phdr));
    if (phdr.p_vaddr == 0) continue;
    fs_lseek(fd, phdr.p_offset, SEEK_SET);
    assert(fs_read(fd, (void *)phdr.p_vaddr, phdr.p_filesz) == phdr.p_filesz);
    memset((void *)(phdr.p_vaddr + phdr.p_filesz), 0, phdr.p_memsz - phdr.p_filesz);
  }

  assert(ehdr.e_entry);
  fs_close(fd);
  return ehdr.e_entry;
}

void naive_uload(PCB *pcb, const char *filename) {
  uintptr_t entry = loader(pcb, filename);
  Log("Jump to entry = %p", entry);
  ((void(*)())entry) ();
}

void context_uload(PCB *pcb, const char *filename, char *const argv[], char *const envp[]) {
  void *ustack_top = new_page(8) + 8 * PGSIZE;

  printf("%p %p\n", argv, envp);

  int argc = 0, envc = 0, len = 0;
  for (; argv[argc]; ++argc) len += strlen(argv[argc]) + 1;
  for (; envp[envc]; ++envc) len += strlen(envp[envc]) + 1;
  len = ROUNDUP(len, sizeof(uintptr_t));

  printf("1231231231243\n");

  char *strtab = ustack_top - len;
  char **sp = (char **)strtab;
  for (int i = envc; i >= 0; --i) {
    *--sp = envp[i];
    if (envp[i]) {
      strcpy(strtab, envp[i]);
      strtab += strlen(envp[i]) + 1;
    }
  }
  for (int i = argc; i >= 0; --i) {
    *--sp = argv[i];
    if (argv[i]) {
      strcpy(strtab, argv[i]);
      strtab += strlen(argv[i]) + 1;
    }
  }
  *(uintptr_t *)--sp = argc;

  uintptr_t entry = loader(pcb, filename);
  Area kstack = { .start = pcb->stack, .end = pcb->stack + STACK_SIZE };
  Context *ctx = ucontext(NULL, kstack, (void *)entry);

  ctx->GPRx = (uintptr_t)sp;
  pcb->cp = ctx;
}
