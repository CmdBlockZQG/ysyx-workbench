#include "common.h"
#include "mem.h"

#include <cstring>

static uint8_t mrom [MROM_SIZE] PG_ALIGN;
static uint8_t sram [SRAM_SIZE] PG_ALIGN;
const MemMap mem_map[] = {
  { "mrom", MROM_BASE, MROM_SIZE, mrom, true },
  { "sram", SRAM_BASE, SRAM_SIZE, sram, false }
};

const MemMap *get_mem_map(addr_t addr, bool panic_if_out) {
  for (const MemMap &i : mem_map) {
    if (i.start <= addr && addr < i.start + i.size) {
      return &i;
    }
  }
  if (panic_if_out) {
    panic("addr = " FMT_ADDR " out of bound", addr);
  } else {
    return nullptr;
  }
}

uint8_t *guest_to_host(addr_t addr) {
  const MemMap *m = get_mem_map(addr, true);
  return addr - m->start + m->ptr;
}

void init_mem() {
  memset(mrom, 0xCB, MROM_SIZE);
  memset(sram, 0xCB, SRAM_SIZE);
}

word_t addr_read(addr_t addr, int len) {
  const MemMap *m = get_mem_map(addr, true);
  return host_read(addr - m->start + m->ptr, len);
}

void addr_write(addr_t addr, int len, word_t data) {
  const MemMap *m = get_mem_map(addr, true);
  Assert(!m->readonly, "addr = " FMT_ADDR " readonly", addr);
  return host_write(addr - m->start + m->ptr, len, data);
}
