#ifndef __MEMORY_PADDR_H__
#define __MEMORY_PADDR_H__

#define MBASE 0x80000000
#define MSIZE 0x8000000
#define PG_ALIGN __attribute((aligned(4096)))

#define PMEM_LEFT ((paddr_t)MBASE)
#define PMEM_RIGHT ((paddr_t)MBASE + MSIZE - 1)

uint8_t *guest_to_host(paddr_t paddr);
paddr_t host_to_guest(uint8_t *haddr);

static inline bool in_pmem(paddr_t addr) {
  return addr - MBASE < MSIZE;
}

word_t paddr_read(paddr_t addr, int len);
void paddr_write(paddr_t addr, int len, word_t data);

#endif
