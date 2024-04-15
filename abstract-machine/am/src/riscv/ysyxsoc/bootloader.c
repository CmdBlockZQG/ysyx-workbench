void _fsbl() __attribute__ ((section ("fsbl")));

void _fsbl() {
  // char *src = &_data_src, *dst = &_data_start;
  // while (dst < &_data_end) *dst++ = *src++;
  // for (dst = &_bss_start; dst < &_bss_end; ++dst) *dst = 0;
  char *src = &_text_src, *dst = &_text_start;
  while (dst < &_text_end) *dst++ = *src++;

  src = &_rodata_src; dst = &_rodata_start;
  while (dst < &_rodata_end) *dst++ = *src++;

  asm volatile("jal _start");
}
