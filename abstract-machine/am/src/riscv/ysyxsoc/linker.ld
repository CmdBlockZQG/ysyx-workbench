ENTRY(_start)
PHDRS { text PT_LOAD; data PT_LOAD; }

MEMORY {
  sram : ORIGIN = 0x0f000000, LENGTH = 8K
  mrom : ORIGIN = 0x20000000, LENGTH = 4K
}

SECTIONS {
  .text : {
    *(entry)
    *(.text*)
  } >mrom AT>mrom : text
  .rodata : {
    *(.srodata*)
    *(.rodata*)
  } >mrom AT>mrom
  .data : {
    _data_start = .;
    *(.data*)
    *(.sdata*)
    _data_end = .;
  } >sram AT>mrom : data
  .bss (NOLOAD) : {
    _bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
    _bss_end = .;
  } >sram

  _data_src = LOADADDR(.data);

  . = _bss_end;
  _stack_top = ALIGN(0x100);
  . = _stack_top + 0x800;
  _stack_pointer = .;
  _heap_start = ALIGN(0x1000);
}
