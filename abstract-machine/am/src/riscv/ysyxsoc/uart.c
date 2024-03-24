#include <am.h>
#include <ysyxsoc.h>

#define LCR_ADDR UART_ADDR + 3
#define DIV_ADDR UART_ADDR

void __am_uart_init() {
  uint8_t lcr_val = inb(LCR_ADDR);
  lcr_val |= 1 << 7;
  outb(LCR_ADDR, lcr_val | (1 << 7));

  outl(DIV_ADDR, 114);

  outb(LCR_ADDR, lcr_val);
}
