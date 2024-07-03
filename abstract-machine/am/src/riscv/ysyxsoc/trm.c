#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <ysyxsoc.h>

#define SDRAM_END 0xa2000000
extern char _heap_start;
Area heap = RANGE(&_heap_start, SDRAM_END);

#ifndef MAINARGS
#define MAINARGS ""
#endif
static const char mainargs[] = MAINARGS;

void putch(char ch) {
  io_write(AM_UART_TX, ch);
}

void halt(int code) {
  asm volatile("ebreak");
  while (1);
}

void _trm_init() {
  // extern char _data_src, _data_start, _data_end, _bss_start, _bss_end;
  // char *src = &_data_src, *dst = &_data_start;
  // while (dst < &_data_end) *dst++ = *src++;
  // for (dst = &_bss_start; dst < &_bss_end; ++dst) *dst = 0;

  // void __am_uart_init();
  // __am_uart_init();

  // uint32_t mvendorid, marchid;
  // asm volatile("csrr %0, mvendorid" : "=r"(mvendorid));
  // asm volatile("csrr %0, marchid" : "=r"(marchid));
  // printf("%c%c%c%c_%u\n", mvendorid >> 24, mvendorid >> 16, mvendorid >> 8, mvendorid, marchid);

  int main(const char *args);
  int ret = main(mainargs);
  halt(ret);
}
