// ALU Funct 常量
// 括号中为funcs为0/1时的运算
parameter reg [2:0] ALU_ADD = 3'b000; // 加减（减法/减法）
parameter reg [2:0] ALU_SHL = 3'b001; // 左移
parameter reg [2:0] ALU_LTS = 3'b010; // 有符号小于
parameter reg [2:0] ALU_LTU = 3'b011; // 无符号小于
parameter reg [2:0] ALU_XOR = 3'b100; // 异或
parameter reg [2:0] ALU_SHR = 3'b101; // 右移（逻辑/算数）
parameter reg [2:0] ALU_OR  = 3'b110; // 或
parameter reg [2:0] ALU_AND = 3'b111; // 与
