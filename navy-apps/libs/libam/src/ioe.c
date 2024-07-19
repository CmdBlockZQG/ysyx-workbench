#include <am.h>
#include <assert.h>
#include <sys/time.h>

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  
}

void __am_timer_uptime(AM_TIMER_UPTIME_T *uptime) {
  struct timeval tv;
  assert(gettimeofday(&tv, NULL) == 0);
  uptime->us = tv.tv_sec * 1000000 + tv.tv_usec;
}

typedef void (*handler_t)(void *buf);
static void *lut[128] = {
  [AM_TIMER_UPTIME] = __am_timer_uptime,
  [AM_INPUT_KEYBRD] = __am_input_keybrd,
};

bool ioe_init() {
  return true;
}

void ioe_read (int reg, void *buf) { ((handler_t)lut[reg])(buf); }
void ioe_write(int reg, void *buf) { ((handler_t)lut[reg])(buf); }
