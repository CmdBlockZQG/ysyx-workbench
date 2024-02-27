#include "Vtop__Dpi.h"
#include "Vtop_top.h"
#include "Vtop_ysyx_23060203_RegFile.h"

#include "common.h"
#include "driver.h"
#include "mem.h"

void halt() {
  // ret a0 x10
  set_npc_state(NPC_END, top->top->RegFile->rf[9]);
}

int mem_read(int raddr) {
  Log("Mem read " FMT_ADDR, raddr);
  word_t rdata = addr_read((addr_t)raddr, 4);
  return *((int *)(&rdata));
}

void mem_write(int waddr, int wdata, char wmask) {
  Log("Mem write " FMT_ADDR " " FMT_WORD " %x", waddr, wdata, (uint32_t)wmask);
  switch (wmask) {
    case 0x01: return addr_write(waddr, 1, wdata);
    case 0x03: return addr_write(waddr, 2, wdata);
    case 0x0f: return addr_write(waddr, 4, wdata);
    IFDEF(RV64, case 0xff: return addr_write(waddr, 8, wdata));
    default: panic("writing memory with invalid mask 0x%x at " FMT_ADDR, \
                   (uint32_t)wmask, waddr);
  }
}
