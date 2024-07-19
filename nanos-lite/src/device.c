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

  return snprintf((char *)buf, len, "k%c %s\n", kbd.keydown ? 'd' : 'u', keyname[kbd.keycode]);
}

size_t dispinfo_read(void *buf, size_t offset, size_t len) {
  AM_GPU_CONFIG_T cfg;
  ioe_read(AM_GPU_CONFIG, &cfg);

  return snprintf(buf, len, "WIDTH:%d\nHEIGHT:%d", cfg.width, cfg.height);
}

size_t fb_write(const void *buf, size_t offset, size_t len) {
  AM_GPU_MEMCPY_T ctl;
  ctl.size = len;
  ctl.dest = offset;
  ctl.src = (void *)buf;
  ioe_write(AM_GPU_MEMCPY, &ctl);
  return len;
}

void init_device() {
  Log("Initializing devices...");
  ioe_init();
}
