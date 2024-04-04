// CSR寄存器地址常量
parameter reg [11:0] CSR_MSTATUS  = 12'h300;
parameter reg [11:0] CSR_MTVEC    = 12'h305;
parameter reg [11:0] CSR_MEPC     = 12'h341;
parameter reg [11:0] CSR_MCAUSE   = 12'h342;

parameter reg [11:0] CSR_MVENDORID = 12'hf11;
parameter reg [11:0] CSR_MARCHID   = 12'hf12;

parameter reg [2:0] CSRF_RW  = 3'b001;
parameter reg [2:0] CSRF_RS  = 3'b010;
parameter reg [2:0] CSRF_RC  = 3'b011;
parameter reg [2:0] CSRF_RWI = 3'b101;
parameter reg [2:0] CSRF_RSI = 3'b110;
parameter reg [2:0] CSRF_RCI = 3'b111;
