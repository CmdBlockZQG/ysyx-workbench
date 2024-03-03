#include "Vtop__Dpi.h"

#include "common.h"
#include "cpu.h"
#include "mem.h"
#include "trace.h"

static const addr_t serial_mmio = 0xa00003f8;
static const addr_t rtc_mmio = 0xa0000048;

void halt() {
  // ret a0 x10
  void difftest_skip_ref();
  difftest_skip_ref();
  set_npc_state(NPC_END, cpu_pc, gpr(10));
}

int mem_read(int raddr) {
#ifdef MTRACE
  mtrace_read(raddr);
#endif
  word_t rdata = addr_read((addr_t)raddr & ~0x3u, 4);
  return *(int *)&rdata;
}

void mem_write(int waddr, int wdata, char wmask) {
  waddr = waddr & ~0x3u;
#ifdef MTRACE
  mtrace_write(waddr, wdata, wmask);
#endif

  if (waddr == serial_mmio) {
    putchar(wdata);
    return;
  }

  if (wmask & 0b0001) addr_write(waddr + 0, 1, wdata >> 0);
  if (wmask & 0b0010) addr_write(waddr + 1, 1, wdata >> 8);
  if (wmask & 0b0100) addr_write(waddr + 2, 1, wdata >> 16);
  if (wmask & 0b1000) addr_write(waddr + 3, 1, wdata >> 24);
}
