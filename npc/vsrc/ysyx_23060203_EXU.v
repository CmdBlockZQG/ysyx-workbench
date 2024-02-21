module ysyx_23060203_EXU (
  // 组合逻辑

  // 计算所需的信息
  input [4:0] rd,
  input [31:0] imm,
  input [31:0] src1,

  // 写回
  output reg_file_wen,
  output [4:0] reg_file_waddr,
  output [31:0] reg_file_wdata
);
  wire [31:0] res;

  // 执行
  assign res = src1 + imm;

  // 写回
  assign reg_file_wen = 1;
  assign reg_file_waddr = rd;
  assign reg_file_wdata = res;
endmodule
