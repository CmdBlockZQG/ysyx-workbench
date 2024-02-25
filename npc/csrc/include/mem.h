#ifndef __MEM_H__
#define __MEM_H__

#include "common.h"

#define MBASE 0x80000000
#define MSIZE 0x8000000
#define PG_ALIGN __attribute((aligned(4096)))

#define MEM_LEFT ((addr_t)MBASE)
#define MEM_RIGHT ((addr_t)MBASE + MSIZE - 1)

uint8_t *guest_to_host(addr_t addr);
addr_t host_to_guest(uint8_t *haddr);

static inline bool in_mem(addr_t addr) {
  return addr - MBASE < MSIZE;
}

static inline word_t host_read(void *addr, int len) {
  switch (len) {
    case 1: return *(uint8_t  *)addr;
    case 2: return *(uint16_t *)addr;
    case 4: return *(uint32_t *)addr;
    IFDEF(RV64, case 8: return *(uint64_t *)addr);
    default: assert(0);
  }
}

static inline void host_write(void *addr, int len, word_t data) {
  switch (len) {
    case 1: *(uint8_t  *)addr = data; return;
    case 2: *(uint16_t *)addr = data; return;
    case 4: *(uint32_t *)addr = data; return;
    IFDEF(RV64, case 8: *(uint64_t *)addr = data; return);
    default: assert(0);
  }
}

word_t addr_read(addr_t addr, int len);
void addr_write(addr_t addr, int len, word_t data);

#endif
