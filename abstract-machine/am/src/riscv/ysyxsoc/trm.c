#include <am.h>
#include <klib-macros.h>
#include <ysyxsoc.h>

int main(const char *args);

extern char _mrom_start;
extern char _sram_start;
#define MROM_SIZE 4096
#define SRAM_SIZE 8192
#define SRAM_END  ((uintptr_t)&_sram_start + SRAM_SIZE)

extern char _heap_start;

Area heap = RANGE(&_heap_start, SRAM_END);
#ifndef MAINARGS
#define MAINARGS ""
#endif
static const char mainargs[] = MAINARGS;

void putch(char ch) {
  outb(UART_ADDR, ch);
}

void halt(int code) {
  asm volatile("ebreak");
  while (1);
}

void _trm_init() {
  int ret = main(mainargs);
  halt(ret);
}
