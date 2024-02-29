#ifndef __TRACE_H__
#define __TRACE_H__

#include "common.h"

void itrace(addr_t pc, uint64_t inst, bool print);
void print_iringbuf();

void ftrace(addr_t pc, addr_t next_pc);

// ----------- elf -----------

typedef uint32_t word_t;

enum { ELF_SYM_FUNC, ELF_SYM_OBJECT };

struct ElfSymbol {
  char *name;
  addr_t addr;
  word_t size;
  int type;
};

#endif