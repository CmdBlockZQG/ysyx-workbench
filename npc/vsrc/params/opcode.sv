// opcode 常量
parameter reg [4:0] OP_LUI    = 5'b01101;
parameter reg [4:0] OP_AUIPC  = 5'b00101;
parameter reg [4:0] OP_JAL    = 5'b11011;
parameter reg [4:0] OP_JALR   = 5'b11001;
parameter reg [4:0] OP_BRANCH = 5'b11000;
parameter reg [4:0] OP_LOAD   = 5'b00000;
parameter reg [4:0] OP_STORE  = 5'b01000;
parameter reg [4:0] OP_CALRI  = 5'b00100;
parameter reg [4:0] OP_CALRR  = 5'b01100;
parameter reg [4:0] OP_SYS    = 5'b11100;
