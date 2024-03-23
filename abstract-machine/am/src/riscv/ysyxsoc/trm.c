#include <am.h>
#include <klib-macros.h>
#include <ysyxsoc.h>

int main(const char *args);

extern char _heap_start;
extern char _stack_top;

Area heap = RANGE(&_heap_start, &_stack_top);
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
