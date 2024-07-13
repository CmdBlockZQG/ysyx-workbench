module ysyx_23060203_ALU (
  input [31:0] alu_a,
  input [31:0] alu_b,

  input [2:0] funct,
  input sw,

  output reg [31:0] val
);

  // `include "def/alu.sv"

  // 是否做减法
  // 是减法需要将alu_b取反，在加法器输入进位
  wire sub = sw | (funct == ALU_LTS) | (funct == ALU_LTU);

  wire [31:0] a = alu_a;
  wire [31:0] b = alu_b ^ {32{sub}};

  reg [31:0] e;
  reg cf; // carry flag 无符号进位标记
  wire sf = e[31]; // sign flag 符号标记
  wire of = (a[31] == b[31]) & (sf ^ a[31]); // overflow flag 补码溢出

  wire [4:0] shift_n = alu_b[4:0];
  // 算术、逻辑右移结果
  wire [31:0] shr;
  right_shifter rshift (
    .a(a), .b(shift_n), .s(sw), .c(shr)
  );

  always_comb begin
    cf = 0;
    case (funct)
      ALU_ADD, ALU_LTS, ALU_LTU:
        {cf, e} = a + b + {31'b0, sub}; // 减法进位输入
      ALU_SHL: e = a << shift_n;
      ALU_XOR: e = a ^ b;
      ALU_SHR: e = shr;
      ALU_OR : e = a | b;
      ALU_AND: e = a & b;
      default: e = 32'b0;
    endcase
  end

  always_comb begin
    case (funct)
      ALU_LTS: val = {31'b0, sf ^ of};
      ALU_LTU: val = {31'b0, ~cf};
      default: val = e;
    endcase
  end

endmodule

module right_shifter (
  input [31:0] a,
  input [4:0] b,
  input s,
  output [31:0] c
);
  wire f = s & a[31];
  wire [31:0] a0 = b[0] ? {f, a[31:1]} : a;
  wire [31:0] a1 = b[1] ? {{2{f}}, a0[31:2]} : a0;
  wire [31:0] a2 = b[2] ? {{4{f}}, a1[31:4]} : a1;
  wire [31:0] a3 = b[3] ? {{8{f}}, a2[31:8]} : a2;
  assign c = b[4] ? {{16{f}}, a3[31:16]} : a3;
endmodule
