#include "common.h"
#include "memory/paddr.h"
#include "memory/host.h"

#include <cstring>

static uint8_t pmem[MSIZE];

uint8_t *guest_to_host(paddr_t paddr) { return pmem + paddr - MBASE; }
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + MBASE; }

static word_t pmem_read(paddr_t addr, int len) {
  return host_read(guest_to_host(addr), len);
}

static void pmem_write(paddr_t addr, int len, word_t data) {
  host_write(guest_to_host(addr), len, data);
}

static void out_of_bound(paddr_t addr) {
  panic("address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR "]",
        addr, PMEM_LEFT, PMEM_RIGHT);
}

void init_mem() {
  memset(pmem, 0xCB, MSIZE);
  Log("physical memory area [" FMT_PADDR ", " FMT_PADDR "]", PMEM_LEFT, PMEM_RIGHT);
}

word_t paddr_read(paddr_t addr, int len) {
  if (in_pmem(addr)) {
    return pmem_read(addr, len);
  }
  out_of_bound(addr);
  return 0;
}

void paddr_write(paddr_t addr, int len, word_t data) {
  if (in_pmem(addr)) {
    return pmem_write(addr, len, data);
  }
  out_of_bound(addr);
}
