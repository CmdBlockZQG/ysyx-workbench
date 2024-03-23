ENTRY(_start)

PHDRS {
  text PT_LOAD;
  data PT_LOAD AT(_data_src);
}

MEMORY {
  sram : ORIGIN = 0x0f000000, LENGTH = 8K
  mrom : ORIGIN = 0x20000000, LENGTH = 4K
}

SECTIONS {
  /* SRAM */
  . = ORIGIN(sram);
  .data : AT(_data_src) {
    _data_start = .;
    *(.data)
    _data_end = .;
  } : data
  .bss : {
    _bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
    _bss_end = .;
  }
  _stack_top = ALIGN(0x100);
  . = _stack_top + 0x800;
  _stack_pointer = .;
  _heap_start = ALIGN(0x1000);

  /* MROM */
  . = ORIGIN(mrom);
  .text : {
    *(entry)
    *(.text*)
  } : text
  .rodata : {
    *(.rodata*)
  }
  _data_src = .;
}