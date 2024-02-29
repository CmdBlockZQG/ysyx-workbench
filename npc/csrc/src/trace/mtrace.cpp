#include "trace.h"

static void locate_object_sym(addr_t addr) {
  extern ElfSymbol elf_symbol_list[];
  extern word_t elf_symbol_list_size;
  for (word_t i = 0; i < elf_symbol_list_size; ++i) {
    if (elf_symbol_list[i].type == ELF_SYM_OBJECT &&
        elf_symbol_list[i].addr <= addr &&
        addr < elf_symbol_list[i].addr + elf_symbol_list[i].size) {
      log_write("(%s + %u)", elf_symbol_list[i].name, (uint32_t)(addr - elf_symbol_list[i].addr));
      return;
    }
  }
}

static const addr_t mtrace_start = 0x80000000;
static const addr_t mtrace_end = 0x87ffffff;

void mtrace_read(addr_t addr) {
  if (mtrace_start <= addr && addr <= mtrace_end) {
    log_write(ANSI_FG_CYAN "[MTRACE] Read " FMT_ADDR, addr);
    locate_object_sym(addr);
    log_write(ANSI_NONE "\n");
  }
}

void mtrace_write(addr_t addr, word_t data, uint8_t mask) {
  for (int i = 0; i < 4; ++i) {
    if ((mask >> i) & 1) {
      addr += i;
      data >>= i * 8;
      break;
    }
  }
  int len = 0;
  for (int i = 0; i < 4; ++i) {
    len += (mask >> i) & 1;
  }
  if (mtrace_start <= addr && addr <= mtrace_end) {
    log_write(ANSI_FG_YELLOW "[MTRACE] Write %d bytes at " FMT_ADDR , len, addr);
    locate_object_sym(addr);
    log_write(": " FMT_WORD ANSI_NONE "\n", data);
  }
}
