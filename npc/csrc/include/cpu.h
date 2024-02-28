#ifndef __CPU_H__
#define __CPU_H__

#include "common.h"

#include "driver.h"
#include "Vtop_top.h"
#include "Vtop_ysyx_23060203_RegFile.h"

void cpu_exec(uint64_t n);

static inline bool check_reg_idx(int idx) {
  Assert(idx >= 0 && idx < MUXDEF(RVE, 16, 32), "Accessing invalid register: x%d", idx);
  return idx;
}

#define gpr(idx) (top->top->RegFile->rf[check_reg_idx(idx) - 1])

static inline const char *reg_name(int idx) {
  extern const char* regs[];
  return regs[check_reg_idx(idx)];
}

void reg_display();
word_t reg_str2val(const char *s, bool *success);

#endif
