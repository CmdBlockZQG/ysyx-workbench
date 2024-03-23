ENTRY(_start)

PHDRS { text PT_LOAD; data PT_LOAD; }

SECTIONS {
  . = 0x20000000; /* MROM */
  .text : {
    *(entry)
    *(.text*)
  } : text
  .rodata : {
    *(.srodata*)
    *(.rodata*)
  }
  _data_src = .;


  /* 为什么不把RAM这段放前面呢？因为LMA会自动增长，.text的LMA会接在.bss后面，除非单独指定 */
  . = 0x0f000000; /* SRAM */
  .data : AT(_data_src) {
    _data_start = .;
    *(.data*) /* 原来的脚本只有一条*(data*)，完全就是空的，AT不生效！ */
    *(.sdata)
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
}
