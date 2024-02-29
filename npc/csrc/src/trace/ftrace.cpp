#include "common.h"

void ftrace(uint64_t pc, uint64_t next_pc) {
  if (next_pc == pc + 4) return;
}