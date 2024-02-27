#include "Vtop__Dpi.h"
#include "Vtop_top.h"
#include "Vtop_ysyx_23060203_RegFile.h"

#include "common.h"
#include "driver.h"
#include "mem.h"

void test_print_reg() {
  printf("--------------------\n");
  for (int i = 1; i < 16; ++i) {
    printf("x%d: " FMT_WORD "\n", i, top->top->RegFile->rf[i - 1]);
  }
}

void halt() {
  set_npc_state(NPC_END, 0); // TODO: read reg a0 as ret
}

int mem_read(int raddr) {
  word_t rdata = addr_read((addr_t)raddr & ~0x3u, 4);
  return *(int *)&rdata;
}

void mem_write(int waddr, int wdata, char wmask) {
  switch (wmask) {
    case 0x01: return addr_write(waddr, 1, wdata);
    case 0x03: return addr_write(waddr, 2, wdata);
    case 0x0f: return addr_write(waddr, 4, wdata);
    IFDEF(RV64, case 0xff: return addr_write(waddr, 8, wdata));
    default: panic("writing memory with invalid mask 0x%x at " FMT_ADDR, \
                   (uint32_t)wmask, waddr);
  }
}
