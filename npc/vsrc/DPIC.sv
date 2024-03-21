import "DPI-C" function void halt();
import "DPI-C" function void inst_complete(input int pc, input int inst);
import "DPI-C" function void skip_difftest();

import "DPI-C" function void uart_putch(input byte ch);

import "DPI-C" function int mem_read(input int raddr);
import "DPI-C" function void mem_write(
  input int waddr,
  input int wdata,
  input byte wmask
);
