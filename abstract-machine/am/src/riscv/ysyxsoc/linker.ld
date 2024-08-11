ENTRY(_start)
/*ENTRY(bootloader)*/
PHDRS { text PT_LOAD; startup PT_LOAD; SSBL PT_LOAD; data PT_LOAD; rodata PT_LOAD; bss PT_LOAD;}

MEMORY
{
    FLASH (rx)  : ORIGIN = 0x30000000, LENGTH = 256M
    SRAM  (rwx) : ORIGIN = 0x0f000000, LENGTH = 8K
    PSRAM (rwx) : ORIGIN = 0x80000000, LENGTH = 4M
    SDRAM (rwx) : ORIGIN = 0xa0000000, LENGTH = 32M
}

SECTIONS {
    startup_LMA = LOADADDR(.startup);
    .startup : {
        . = ALIGN(0x8);
        _start_startup_addr = .;
        *(entry)
        *(.startup)
        . = ALIGN(0x8);
        _end_startup_addr = .;
    } >FLASH AT>FLASH : startup

    SSBL_LMA = LOADADDR(.SSBL);
    .SSBL : {
        . = ALIGN(0x8);
        _start_ssbl_addr = .;
        *(.SSBL)
        . = ALIGN(0x8);
        _end_ssbl_addr = .;
    } >SRAM AT>FLASH : SSBL

    text_LMA = LOADADDR(.text);
    .text : {
        . = ALIGN(0x8);
        _start_text_addr = .;
        *(.text*)
        . = ALIGN(0x8);
        _end_text_addr = .;
    } >SDRAM AT>FLASH : text
    etext = .;

    rodata_LMA = LOADADDR(.rodata);
    .rodata : {
        . = ALIGN(0x8);
        _start_rodata_addr = .;
        *(.rodata*)
        *(.srodata.*)
        . = ALIGN(0x8);
        _end_rodata_addr = .;
    } >SDRAM AT>FLASH : rodata

    data_LMA = LOADADDR(.data);
    .data : {
        . = ALIGN(0x8);
        _start_data_addr = .;
        *(.data)
        *(.data.*)
        . = ALIGN(0x8);
        _end_data_addr = .;
    } >SDRAM AT>FLASH : data
    _addr2 = .;

    .bss : {
        . = ALIGN(0x8);
        bss_start = .;
        *(.bss*)
        *(.sbss*)
        *(.scommon)
        . = ALIGN(0x8);
        bss_end = .;
    } >SDRAM : bss
    _end_addr = .;
    _psram_heap_base = ALIGN(0x8);
    _stack_pointer = 0x0f002000;
    _trm_init_addr = _trm_init;
    _SSBL_addr = bootloader;
}