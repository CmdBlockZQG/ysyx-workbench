void _fsbl() __attribute__ ((section ("fsbl")));
void _ssbl() __attribute__ ((section ("ssbl")));

void _fsbl() {
  extern char _ssbl_src, _ssbl_start, _ssbl_end;
  char *src = &_ssbl_src, *dst = &_ssbl_start;
  while (dst < &_ssbl_end) *dst++ = *src++;

  asm volatile("tail _ssbl");
}

void _ssbl() {
  extern char _rodata_src, _rodata_start, _rodata_end;
  char *src = &_rodata_src, *dst = &_rodata_start;
  while (dst < &_rodata_end) *dst++ = *src++;

  extern char _text_src, _text_start, _text_end;
  src = &_text_src, dst = &_text_start;
  while (dst < &_text_end) *dst++ = *src++;

  volatile char *test = &_text_start;
  for (volatile int i = 1; i <= 32; ++i) {
    *(volatile char *)&_rodata_start = *test;
    test++;
  }

  asm volatile("tail _start");
}
