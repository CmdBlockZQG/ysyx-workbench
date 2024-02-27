import "DPI-C" function void halt();

import "DPI-C" function int mem_read(input int raddr);
import "DPI-C" function void mem_write(
  input int waddr,
  input int wdata,
  input byte wmask
);
