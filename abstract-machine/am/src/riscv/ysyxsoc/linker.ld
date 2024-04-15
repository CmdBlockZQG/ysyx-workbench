ENTRY(_fsbl)
PHDRS { bl PT_LOAD; text PT_LOAD; data PT_LOAD; }

MEMORY {
  sram  : ORIGIN = 0x0f000000, LENGTH = 8K
  mrom  : ORIGIN = 0x20000000, LENGTH = 4K
  flash : ORIGIN = 0x30000000, LENGTH = 16M
  psram : ORIGIN = 0x80000000, LENGTH = 4M
}

SECTIONS {
  fsbl : {
    *(fsbl)
  } >flash AT>flash : bl

  .text : {
    _text_start = .;
    *(entry)
    *(.text*)
    _text_end = .;
  } >psram AT>flash : text
  .rodata : {
    _rodata_start = .;
    *(.srodata*)
    *(.rodata*)
    _rodata_end = .;
  } >psram AT>flash : text
  
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
  } >psram : data

  _text_src = LOADADDR(.text);
  _rodata_src = LOADADDR(.rodata);
  _data_src = LOADADDR(.data);
  . = _bss_end;
  _heap_start = ALIGN(0x1000);

  _stack_top = ORIGIN(sram);
  _stack_pointer = ORIGIN(sram) + LENGTH(sram);
}
