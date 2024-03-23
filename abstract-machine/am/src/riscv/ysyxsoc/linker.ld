ENTRY(_start)
PHDRS { text PT_LOAD; data PT_LOAD; }

/* _mrom_start and _sram_start are defined in LDFLAGS */

SECTIONS {

  /* SRAM 0x0f000000 0x2000(8K) */
  . = 0x0f000000;
  _heap_start = ALIGN(0x10000);
  
  . += 0x1800;
  _stack_top = ALIGN(0x100);
  . = _stack_top + 0x800;
  _stack_pointer = .;
  

  /* MROM 0x20000000 0x1000(4K) */
  . = 0x20000000;
  .text : {
    *(entry)
    *(.text*)
  } : text
  etext = .;
  _etext = .;
  .rodata : {
    *(.rodata*)
  }
  .data : {
    *(.data)
  } : data
  edata = .;
  _data = .;
  .bss : {
	_bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  }
  
  end = .;
  _end = .;
}
