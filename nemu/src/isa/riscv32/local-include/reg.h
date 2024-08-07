/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#ifndef __RISCV_REG_H__
#define __RISCV_REG_H__

#include <common.h>

static inline int check_reg_idx(int idx) {
  IFDEF(CONFIG_RT_CHECK, assert(idx >= 0 && idx < MUXDEF(CONFIG_RVE, 16, 32)));
  return idx;
}

#define gpr(idx) (cpu.gpr[check_reg_idx(idx)])

static inline const char* reg_name(int idx) {
  extern const char* regs[];
  return regs[check_reg_idx(idx)];
}

extern word_t csr_mstatus, csr_mtvec, csr_mepc, csr_mcause;
extern word_t csr_satp, csr_mscratch, csr_mvendorid, csr_marchid;
extern word_t csr_mhartid, csr_mvendorid, csr_marchid;

static inline word_t *csr_ptr(word_t x) {
  switch (x & 0xfff) {
    case 0x300: return &csr_mstatus;
    case 0x305: return &csr_mtvec;
    case 0x341: return &csr_mepc;
    case 0x342: return &csr_mcause;
    case 0x180: return &csr_satp;
    case 0x340: return &csr_mscratch;
    case 0xf11: return &csr_mvendorid;
    case 0xf12: return &csr_marchid;
    case 0xf14: return &csr_mhartid;
  }
  assert(0);
}

#endif
