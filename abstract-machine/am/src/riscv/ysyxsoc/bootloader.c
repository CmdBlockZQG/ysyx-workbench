void _fsbl() __attribute__ ((section ("fsbl")));

void _fsbl() {
  extern char _text_src, _text_start, _text_end;
  char *src = &_text_src, *dst = &_text_start;
  while (dst < &_text_end) *dst++ = *src++;

  extern char _rodata_src, _rodata_start, _rodata_end;
  src = &_rodata_src; dst = &_rodata_start;
  while (dst < &_rodata_end) *dst++ = *src++;

  asm volatile("tail _start");
}
