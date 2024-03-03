#include "Vtop__Dpi.h"

#include "common.h"
#include "cpu.h"
#include "mem.h"
#include "trace.h"

static const addr_t serial_mmio = 0xa00003f8;
static const addr_t rtc_mmio = 0xa0000048;

void difftest_skip_ref();

void halt() {
  // ret a0 x10
  difftest_skip_ref();
  set_npc_state(NPC_END, cpu_pc, gpr(10));
}

int mem_read(int raddr) {
  raddr = raddr & ~0x3u;
#ifdef MTRACE
  mtrace_read(raddr);
#endif

  if (raddr == rtc_mmio || raddr == rtc_mmio + 4) {
    difftest_skip_ref();
    union {
      uint64_t t;
      int s[2];
    } t;
    t.t = std::chrono::time_point_cast<std::chrono::nanoseconds> \
          (std::chrono::system_clock::now()).time_since_epoch().count();
    return raddr == rtc_mmio ? t.s[0] : t.s[1];
  }

  assert(in_mem(raddr));

  word_t rdata = addr_read((addr_t)raddr, 4);
  return *(int *)&rdata;
}

void mem_write(int waddr, int wdata, char wmask) {
  waddr = waddr & ~0x3u;
#ifdef MTRACE
  mtrace_write(waddr, wdata, wmask);
#endif

  if (waddr == serial_mmio) {
    putchar(wdata);
    difftest_skip_ref();
    return;
  }

  if (wmask & 0b0001) addr_write(waddr + 0, 1, wdata >> 0);
  if (wmask & 0b0010) addr_write(waddr + 1, 1, wdata >> 8);
  if (wmask & 0b0100) addr_write(waddr + 2, 1, wdata >> 16);
  if (wmask & 0b1000) addr_write(waddr + 3, 1, wdata >> 24);
}
