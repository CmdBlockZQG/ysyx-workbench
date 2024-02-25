#include "common.h"
#include "mem.h"

#include <cstring>

static uint8_t pmem[MSIZE];

uint8_t *guest_to_host(addr_t addr) { return pmem + addr - MBASE; }
addr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + MBASE; }

static word_t pmem_read(addr_t addr, int len) {
  return host_read(guest_to_host(addr), len);
}

static void pmem_write(addr_t addr, int len, word_t data) {
  host_write(guest_to_host(addr), len, data);
}

static void out_of_bound(addr_t addr) {
  panic("address = " FMT_ADDR " is out of bound of pmem [" FMT_ADDR ", " FMT_ADDR "]",
        addr, MEM_LEFT, MEM_RIGHT);
}

void init_mem() {
  memset(pmem, 0xCB, MSIZE);
  Log("physical memory area [" FMT_ADDR ", " FMT_ADDR "]", MEM_LEFT, MEM_RIGHT);
}

word_t addr_read(addr_t addr, int len) {
  if (in_mem(addr)) {
    return pmem_read(addr, len);
  }
  out_of_bound(addr);
  return 0;
}

void addr_write(addr_t addr, int len, word_t data) {
  if (in_mem(addr)) {
    return pmem_write(addr, len, data);
  }
  out_of_bound(addr);
}
