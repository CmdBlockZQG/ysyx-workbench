#include <am.h>
#include <ysyxsoc.h>

#define LCR_ADDR UART_ADDR + 3
#define DIV_ADDR UART_ADDR

void __am_uart_init() {
  const uint8_t lcr_val = inb(LCR_ADDR);
  outb(LCR_ADDR, lcr_val | (1 << 7));

  outb(DIV_ADDR, 10);
  outb(DIV_ADDR + 1, 0);

  outb(LCR_ADDR, lcr_val);
}
