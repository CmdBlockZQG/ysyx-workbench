#include <am.h>
#include <klib-macros.h>
#include <klib.h>
#include <ysyxsoc.h>

int main(const char *args);
//堆区3kb
#define SRAM_HEAP_SIZE (1024*3)
#define SRAM_HEAP_END  ((uintptr_t)&_psram_heap_base + SRAM_HEAP_SIZE)
#define UART_BASE 0x10000000
#define UART_LCR_OFFSET 0x3
#define UART_DLR_LSB_OFFSET 0x0
#define UART_DLR_MSB_OFFSET 0x1
#define UART_LSR_OFFSET 0x5 // Line Status Register
#define UART_MCR_OFFSET 0x4 // Modem Control Register

extern char _psram_heap_base;
Area heap = RANGE(&_psram_heap_base, SRAM_HEAP_END);
#ifndef MAINARGS
#define MAINARGS ""
#endif
static const char mainargs[] = MAINARGS;
 
# define npc_trap(code) asm volatile("mv a0, %0; ebreak" : :"r"(code))

void putch(char ch) {
  // fifo位置挺大的，但是似乎只能一个个字节写入，因为写入的寄存器位宽为8
  unsigned char a = 0;
  while(1){ 
    a = *(volatile unsigned char *)(UART_BASE + UART_LSR_OFFSET) & (1 << 5);
    a = a >> 5;
    if(a == 1){
      break;
    }
  } // 在等待寄存器第五位为1，代表fifo为空
  uintptr_t addr = UART_BASE;
  *(volatile uint8_t *)addr = ch;
  return;
}

void halt(int code) {
  npc_trap(code);
  while (1);
}

extern char _start_ssbl_addr;
extern char _end_ssbl_addr;
extern char SSBL_LMA;
extern char _SSBL_addr;
void __attribute__((section(".startup"))) FSBLoder(){ // 之后跳转到SSBL
  uint32_t* sram_ssbl = (uint32_t*)&_start_ssbl_addr;
  uint32_t* flash_ssbl = (uint32_t*)&SSBL_LMA;
  while(sram_ssbl < (uint32_t*)&_end_ssbl_addr) {
    *sram_ssbl++ = *flash_ssbl++;
  }
  uintptr_t SSBL_addr = (uintptr_t)&_SSBL_addr;
  __asm__ volatile ( "mv t0, x0" );
  __asm__ volatile ( "add t0, t0, %0" : : "r"(SSBL_addr));
  __asm__ volatile ( "jalr 0(t0)");
}

extern char rodata_LMA;
extern char _start_rodata_addr;
extern char _end_rodata_addr;

extern char data_LMA;
extern char _end_data_addr;
extern char _start_data_addr;

extern char bss_start;
extern char bss_end;

extern char text_LMA;
extern char _start_text_addr;
extern char _end_text_addr;

extern char _trm_init_addr;

void __attribute__((section(".SSBL"))) bootloader(){
  //text
  //uintptr_t _start_text_addr1 = (uintptr_t)(&_start_text_addr);
  uint32_t *sdram_text = (uint32_t *)&_start_text_addr;
  uint32_t *flash_text = (uint32_t *)&text_LMA;
  while(sdram_text < (uint32_t*)&_end_text_addr){
    *sdram_text++ = *flash_text++;
  }
  //rodata
  uint32_t *sdram_rodata  = (uint32_t*)&_start_rodata_addr;
  uint32_t *flash_rodata = (uint32_t*)&rodata_LMA;
  while(sdram_rodata < (uint32_t*)&_end_rodata_addr){
    *sdram_rodata++ = *flash_rodata++;
  }
  //data
  uint32_t *sdram_data  = (uint32_t*)&_start_data_addr;
  uint32_t *flash_data = (uint32_t*)&data_LMA;
  while(sdram_data < (uint32_t*)&_end_data_addr){
    *sdram_data++ = *flash_data++;
  }
  for(sdram_data = (uint32_t*)&bss_start; sdram_data < (uint32_t*)&bss_end; sdram_data++){
    *sdram_data = 0;
  }
  uintptr_t trm_init_addr1 = (uintptr_t)&_trm_init_addr;
  __asm__ volatile ( "mv t0, x0" );
  __asm__ volatile ( "add t0, t0, %0" : : "r"(trm_init_addr1));
  __asm__ volatile ( "jalr 0(t0)");
}

void uart_init(){
  unsigned int baud = 0x6;
  // LCR
  *(volatile unsigned char*)(UART_BASE + UART_LCR_OFFSET) = 1 << 7; // 波特率在第七位上
  *(volatile unsigned char*)(UART_BASE + UART_DLR_LSB_OFFSET) = baud & 0xff;
  *(volatile unsigned char*)(UART_BASE + UART_DLR_MSB_OFFSET) = (baud >> 8) & 0xff;
  *(volatile unsigned char*)(UART_BASE + UART_LCR_OFFSET) = 0x00;
  *(volatile unsigned char*)(UART_BASE + UART_LCR_OFFSET) = 0x7;
  // MCR
  *(volatile unsigned char*)(UART_BASE + UART_MCR_OFFSET) = 0x0;
}

// 需要约定mvendorid和marchid的序号。当做这个的时候，可以考虑改csr的数据通路，不要用前递，用冲刷
// 若检测到csr的跳转之类的，让ifu的pc到跳转的目的地址，然后其他的流水线全部冲掉，这样就不用冲刷了
/*void out_student_id(){
  int ysyx_index = 0;
  int id_index   = 0;
  uint64_t ysyx_ascii = 0;
  uint64_t student_id = 0;
  asm volatile ("csrr %0 %1" : "=r"(ysyx_ascii) : "i"(index));
  *(volatile )
}*/

void _trm_init() {
  uart_init();
  //bootloader();
  int ret = main(mainargs);//返回0给ret
  halt(ret);
}