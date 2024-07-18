#include <common.h>
#include <device.h>

#if defined(MULTIPROGRAM) && !defined(TIME_SHARING)
# define MULTIPROGRAM_YIELD() yield()
#else
# define MULTIPROGRAM_YIELD()
#endif

#define NAME(key) \
  [AM_KEY_##key] = #key,

static const char *keyname[256] __attribute__((used)) = {
  [AM_KEY_NONE] = "NONE",
  AM_KEYS(NAME)
};

size_t serial_write(const void *buf, size_t offset, size_t len) {
  for (int i = 0; i < len; ++i) putch(((const char *)buf)[i]);
  return len;
}

size_t events_read(void *buf, size_t offset, size_t len) {
  AM_INPUT_KEYBRD_T kbd;
  ioe_read(AM_INPUT_KEYBRD, &kbd);
  if (!kbd.keycode) return 0;

  char str[20];
  const char *e_name = keyname[kbd.keycode];
  sprintf(str, "k%c %s\n", kbd.keydown ? 'd' : 'u', e_name);
  size_t e_len = strlen(e_name) + 4; // \n结尾，不包含\0

  size_t res = MIN(len, e_len);
  for (size_t i = 0; i < res; ++i) {
    *(char *)buf++ = str[i];
  }
  
  return res;
}

size_t dispinfo_read(void *buf, size_t offset, size_t len) {
  AM_GPU_CONFIG_T cfg;
  ioe_read(AM_GPU_CONFIG, &cfg);
  char str[64];
  sprintf(str, "WIDTH:%d\nHEIGHT:%d", cfg.width, cfg.height);
  size_t f_len = strlen(str) + 1; // 包含结尾的\0
  
  size_t res = MIN(len, f_len);
  for (size_t i = 0; i < res; ++i) {
    *(char *)buf++ = str[i];
  }
  return 0;
}

size_t fb_write(const void *buf, size_t offset, size_t len) {
  return 0;
}

void init_device() {
  Log("Initializing devices...");
  ioe_init();
}
