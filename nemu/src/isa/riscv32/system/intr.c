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

#include <isa.h>

extern word_t csr_mstatus, csr_mtvec, csr_mepc, csr_mcause;

word_t isa_raise_intr(word_t NO, vaddr_t epc) {
#ifdef CONFIG_ETRACE
  Log("[ETRACE] exception triggered at pc = " FMT_PADDR, epc);
#endif
  csr_mepc = epc;
  csr_mcause = NO;
  return csr_mtvec;
}

word_t isa_query_intr() {
  return INTR_EMPTY;
}
