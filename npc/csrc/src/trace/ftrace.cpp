#include "common.h"
#include "trace.h"

extern ElfSymbol elf_symbol_list[];
extern word_t elf_symbol_list_size;
static word_t ftrace_dep = 0;

static word_t get_func_sym_ndx(addr_t p) {
  word_t res = 0;
  addr_t res_off = -1;
  for (word_t i = 0; i < elf_symbol_list_size; ++i) {
    if (elf_symbol_list[i].type == ELF_SYM_FUNC && elf_symbol_list[i].addr <= p) {
      if (p < elf_symbol_list[i].addr + elf_symbol_list[i].size) return i;
      addr_t off = p - elf_symbol_list[i].addr;
      if (off < res_off) {
        res_off = off;
        res = i;
      }
    }
  }
  Log(ANSI_FMT("[FTRACE] Warning: PC outside any FUNC symbol area: " FMT_ADDR, ANSI_FG_YELLOW), p);
  return res;
}

void ftrace(addr_t pc, addr_t next_pc) {
  if (next_pc == pc + 4 || elf_symbol_list_size == 0) return;
  word_t from = get_func_sym_ndx(pc), to = get_func_sym_ndx(next_pc);
  if (from == to) return;
  log_write("[FTRACE] " FMT_ADDR ": ", pc);
  if (elf_symbol_list[to].addr == next_pc) { // call, jump to the begging of a func
    for (int i = 0; i < ftrace_dep; ++i) log_write("| ");
    ++ftrace_dep;
    log_write("call [%s@" FMT_ADDR "] -> [%s@" FMT_ADDR "]\n",
              elf_symbol_list[from].name,
              elf_symbol_list[from].addr,
              elf_symbol_list[to].name,
              elf_symbol_list[to].addr);
  } else { // ret, return to calling position
    Assert(ftrace_dep, "Error occured in FTRACE: negative deepth");
    --ftrace_dep;
    for (int i = 0; i < ftrace_dep; ++i) log_write("| ");
    log_write("ret [%s@" FMT_ADDR "] -> [%s@" FMT_ADDR "]:" FMT_ADDR "\n",
              elf_symbol_list[from].name,
              elf_symbol_list[from].addr,
              elf_symbol_list[to].name,
              elf_symbol_list[to].addr,
              next_pc);
  }
}
