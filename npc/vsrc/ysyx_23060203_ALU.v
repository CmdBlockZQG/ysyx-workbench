module ysyx_23060203_ALU (
  // 组合逻辑,无时钟和复位

  input [31:0] alu_a,
  input [31:0] alu_b,

  input [2:0] funct,
  input funcs, // 不需要时必须为0

  output reg [31:0] val
);
  `include "params/alu.v"

  // 需要做减法的情况：减法、比较（有符号/无符号）
  wire sub = funcs | (funct == ALU_LTS) | (funct == ALU_LTU);
  // wire sub = ((funct == ALU_ADD) & funcs) | (funct == ALU_LTS) | (funct == ALU_LTU);
  // 这里简化是因为funcs只在减法和位移时为1，而位移时位移位数有单独的bs，不会被取反影响
  wire [31:0] a = alu_a;
  wire [31:0] b = alu_b ^ {32{sub}}; // 做减法需要将b取反
  wire [31:0] bs = {27'b0, alu_b[4:0]}; // 位移指令，移动位数高位舍弃

  reg [31:0] e; // 直接计算结果
  reg cf; // 无符号进位
  wire sf = e[31]; // 符号
  wire of = (a[31] == b[31]) & (sf ^ a[31]); // 有符号溢出
  // 1算数右移，0逻辑右移
  wire signed [31:0] shr_res = funcs ? $signed(a) >>> $signed(bs) : a >> bs;

  always_comb begin
    cf = 0;
    case (funct)
      ALU_ADD, ALU_LTS, ALU_LTU: {cf, e} = a + b + {31'b0, sub}; // 减法需要加一个1
      ALU_SHL: e = a << bs;
      ALU_XOR: e = a ^ b;
      ALU_SHR: e = shr_res;
      ALU_OR : e = a | b;
      ALU_AND: e = a & b;
      default: e = 32'b0;
    endcase
  end

  always_comb begin
    case (funct)
      ALU_LTS: val = {31'b0, sf ^ of};
      ALU_LTU: val = {31'b0, !cf};
      default: val = e;
    endcase
  end
endmodule
