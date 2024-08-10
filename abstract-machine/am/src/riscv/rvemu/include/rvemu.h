#ifndef NPC_H__
#define NPC_H__

#include <klib-macros.h>

#include ISA_H

#define DEVICE_BASE 0xa0000000
#define SERIAL_PORT 0x09000000
#define RTC_ADDR    0x09001000
#define CLINT_ADDR  0x20000000

extern char _pmem_start;
#define PMEM_SIZE (128 * 1024 * 1024)
#define PMEM_END  ((uintptr_t)&_pmem_start + PMEM_SIZE)

#define NPC_PADDR_SPACE \
  RANGE(&_pmem_start, PMEM_END), \
  RANGE(SERIAL_PORT, SERIAL_PORT + 0x2000), \
  RANGE(CLINT_ADDR, CLINT_ADDR + 0xc000)

typedef uintptr_t PTE;

#define PGSIZE 4096

#endif
