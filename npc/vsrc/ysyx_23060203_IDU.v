module ysyx_23060203_IDU (
  // 组合逻辑,无时钟和复位

  input [31:0] inst,

  output [4:0] rd,
  output [31:0] src1,
  output [31:0] imm,

  output [4:0] reg_file_raddr,
  input [31:0] reg_file_rdata
);
  wire [4:0] rs1;

  assign imm = {{20{inst[31]}}, inst[31:20]};
  assign rd = inst[11:7];
  assign rs1 = inst[19:15];

  // 寄存器文件的读取是组合逻辑
  assign reg_file_raddr = rs1;
  assign src1 = reg_file_rdata;
endmodule
