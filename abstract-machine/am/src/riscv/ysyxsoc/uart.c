#include <am.h>
#include <ysyxsoc.h>

#define LCR_ADDR UART_ADDR + 3
#define DIV_ADDR UART_ADDR
#define FCR_ADDR UART_ADDR + 2
#define IER_ADDR UART_ADDR + 1

void __am_uart_init() {
  outb(LCR_ADDR, 0b10000011);
  outb(DIV_ADDR + 1, 0);
  outb(DIV_ADDR, 1);
  outb(LCR_ADDR, 0b00000011);
  // outb(FCR_ADDR, 0b11000110);
  // outb(IER_ADDR, 0b00000000);
}
