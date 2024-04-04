#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <ysyxsoc.h>

#define SRAM_END 0x0f002000
extern char _heap_start;
Area heap = RANGE(&_heap_start, SRAM_END);

#ifndef MAINARGS
#define MAINARGS ""
#endif
static const char mainargs[] = MAINARGS;

void putch(char ch) {
  while (!((inb(UART_ADDR + 5) >> 5) & 1));
  outb(UART_ADDR, ch);
}

void halt(int code) {
  asm volatile("ebreak");
  while (1);
}

extern char _data_src, _data_start, _data_end, _bss_start, _bss_end;
int main(const char *args);

void __am_uart_init();
void _trm_init() {
  char *src = &_data_src, *dst = &_data_start;
  while (dst < &_data_end) *dst++ = *src++;
  for (dst = &_bss_start; dst < &_bss_end; ++dst) *dst = 0;

  __am_uart_init();

  uint32_t mvendorid, marchid;
  asm volatile("csrr %0, mvendorid" : "=r"(mvendorid));
  asm volatile("csrr %0, marchid" : "=r"(marchid));
  for (int i = 0; i < 4; ++i) {
    putch(mvendorid & 0xff);
    mvendorid >>= 8;
  }
  printf("_%u\n", marchid);

  int ret = main(mainargs);
  halt(ret);
}
