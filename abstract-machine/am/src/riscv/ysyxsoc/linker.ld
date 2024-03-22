ENTRY(_start)
PHDRS { text PT_LOAD; data PT_LOAD; }

/* _mrom_start and _sram_start are defined in LDFLAGS */

SECTIONS {

  /* SRAM */
  . = _sram_start;
  _stack_top = ALIGN(0x1000);
  . = _stack_top + 0x800;
  _stack_pointer = .;
  _heap_start = ALIGN(0x10000);

  /* MROM */
  . = _mrom_start;
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
