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
  difftest_skip_ref();
  set_npc_state(NPC_END, cpu_pc, gpr(10));
}

static uint64_t get_time() {
  return std::chrono::time_point_cast<std::chrono::microseconds> \
         (std::chrono::high_resolution_clock::now()).time_since_epoch().count();
}

int mem_read(int raddr) {
  raddr = raddr & ~0x3u;
#ifdef MTRACE
  mtrace_read(raddr);
#endif

  static uint64_t boot_time = 0;
  if (!boot_time) boot_time = get_time();
  if (raddr == rtc_mmio || raddr == rtc_mmio + 4) {
#ifdef DIFFTEST
    difftest_skip_ref_next();
#endif
    union {
      uint64_t t;
      int s[2];
    } t;
    t.t = get_time() - boot_time;
    return raddr == rtc_mmio ? t.s[0] : t.s[1];
  }

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
#ifdef DIFFTEST
    difftest_skip_ref();
#endif
    return;
  }

  if (wmask & 0b0001) addr_write(waddr + 0, 1, wdata >> 0);
  if (wmask & 0b0010) addr_write(waddr + 1, 1, wdata >> 8);
  if (wmask & 0b0100) addr_write(waddr + 2, 1, wdata >> 16);
  if (wmask & 0b1000) addr_write(waddr + 3, 1, wdata >> 24);
}
