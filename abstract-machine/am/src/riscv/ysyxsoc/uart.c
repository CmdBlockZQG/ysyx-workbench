#include <am.h>
#include <ysyxsoc.h>

#define LCR_ADDR UART_ADDR + 3
#define DIV_ADDR UART_ADDR

void __am_uart_init() {
  outb(LCR_ADDR, 0b10000011);

  outb(DIV_ADDR + 1, 0);
  outb(DIV_ADDR, 10);

  outb(LCR_ADDR, 0b00000011);
}
