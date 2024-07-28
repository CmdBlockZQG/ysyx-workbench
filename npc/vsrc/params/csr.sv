// CSR寄存器地址常量
parameter CSR_MSTATUS  = 12'h300;
parameter CSR_MTVEC    = 12'h305;
parameter CSR_MEPC     = 12'h341;
parameter CSR_MCAUSE   = 12'h342;

parameter CSR_MVENDORID = 12'hf11;
parameter CSR_MARCHID   = 12'hf12;

parameter CSRF_RW  = 3'b001;
parameter CSRF_RS  = 3'b010;
parameter CSRF_RC  = 3'b011;
parameter CSRF_RWI = 3'b101;
parameter CSRF_RSI = 3'b110;
parameter CSRF_RCI = 3'b111;
