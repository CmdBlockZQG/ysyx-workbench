#ifndef YSYXSOC_H__
#define YSYXSOC_H__

#include <klib-macros.h>

#include ISA_H

#define CLINT_ADDR 	0x02000000
#define  UART_ADDR  0x10000000
#define  GPIO_ADDR  0x10002000
#define   PS2_ADDR  0x10011000
#define   VGA_ADDR  0x21000000

#define SRAM_BASE  0x0f000000
#define SRAM_SIZE  (8 * 1024)
#define SDRAM_BASE 0xa0000000
#define SDRAM_SIZE (128 * 1024 * 1024)

extern char _pmem_start;
#define PMEM_SIZE (128 * 1024 * 1024)
#define PMEM_END  ((uintptr_t)&_pmem_start + PMEM_SIZE)

#define YSYXSOC_PADDR_SPACE \
  RANGE(SRAM_BASE, SRAM_BASE + SRAM_SIZE), \
  RANGE(SDRAM_BASE, SDRAM_BASE + SDRAM_SIZE), \
  RANGE(CLINT_ADDR, CLINT_ADDR + 0xc000), \
  RANGE(UART_ADDR, UART_ADDR + 0x12000), \
  RANGE(VGA_ADDR, VGA_ADDR + 2 * 1024 * 1024)

typedef uintptr_t PTE;

#define PGSIZE 4096

#endif
