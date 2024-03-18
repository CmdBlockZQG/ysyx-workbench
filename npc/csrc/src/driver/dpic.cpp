#include "Vtop__Dpi.h"

#include "common.h"
#include "cpu.h"
#include "mem.h"
#include "trace.h"

static const addr_t serial_mmio = 0xa00003f8;
static const addr_t rtc_mmio = 0xa0000048;

#ifdef DIFFTEST
void difftest_skip_ref();
void difftest_skip_ref_next();
#endif

void halt() {
  // ret a0 x10
#ifdef DIFFTEST
  difftest_skip_ref();
#endif
  set_npc_state(NPC_END, cpu_pc, gpr(10));
}

bool exec_once_flag;
void inst_complete(int new_pc) {
  cpu_pc = new_pc;
  exec_once_flag = true;
}

void uart_putch(char c) {
  putchar(c);
}

int mem_read(int raddr) {
  raddr = raddr & ~0x3u;
#ifdef MTRACE
  mtrace_read(raddr);
#endif
  word_t rdata = addr_read((addr_t)raddr, 4);
  return *(int *)&rdata;
}

void mem_write(int waddr, int wdata, char wmask) {
  waddr = waddr & ~0x3u;
#ifdef MTRACE
  mtrace_write(waddr, wdata, wmask);
#endif

  if (wmask & 0b0001) addr_write(waddr + 0, 1, wdata >> 0);
  if (wmask & 0b0010) addr_write(waddr + 1, 1, wdata >> 8);
  if (wmask & 0b0100) addr_write(waddr + 2, 1, wdata >> 16);
  if (wmask & 0b1000) addr_write(waddr + 3, 1, wdata >> 24);
}
