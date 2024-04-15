ENTRY(_start)
PHDRS { text PT_LOAD; data PT_LOAD; }

MEMORY {
  sram  : ORIGIN = 0x0f000000, LENGTH = 8K
  mrom  : ORIGIN = 0x20000000, LENGTH = 4K
  flash : ORIGIN = 0x30000000, LENGTH = 16M
  psram : ORIGIN = 0x80000000, LENGTH = 4M
}

SECTIONS {
  .text : {
    *(entry)
    *(.text*)
  } >flash AT>flash : text
  .rodata : {
    *(.srodata*)
    *(.rodata*)
  } >flash AT>flash
  .data : {
    _data_start = .;
    *(.data*)
    *(.sdata*)
    _data_end = .;
  } >psram AT>flash : data
  .bss (NOLOAD) : {
    _bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
    _bss_end = .;
  } >psram

  _data_src = LOADADDR(.data);
  . = _bss_end;
  _heap_start = ALIGN(0x1000);

  _stack_top = ORIGIN(psram);
  _stack_pointer = ORIGIN(psram) + 0x800;
}
