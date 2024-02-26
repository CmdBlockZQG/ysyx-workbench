module ysyx_23060203_EXU (
  // 组合逻辑,无时钟和复位

  // 连接IDU输出
  input [4:0] opcode,
  input [2:0] funct,
  input [4:0] rd,
  input [11:0] csr,
  input [31:0] src2,

  // 连接ALU输出
  input [31:0] alu_val,

  // 寄存器写
  output reg reg_wen,
  output [4:0] reg_waddr,
  output reg [31:0] reg_wdata,

  // 连接访存模块
  output [2:0] mem_rfunc,
  output [31:0] mem_raddr,
  input [31:0] mem_rdata,
  output mem_wen,
  output [2:0] mem_wfunc,
  output [31:0] mem_waddr,
  output reg [31:0] mem_wdata
);
  `include "params/opcode.v"

  // -------------------- 寄存器写 --------------------
  assign reg_wen = (opcode != OP_BRANCH) & (opcode != OP_STORE); // 寄存器写端口使能，只有这么两种指令不写寄存器
  assign reg_waddr = rd;
  assign reg_wdata = (opcode == OP_LOAD) ? mem_rdata : alu_val; // 除了读内存之外，都是写alu运算结果
  /* always_comb begin
    case (opcode)
      OP_LUI, OP_AUIPC, OP_JAL, OP_JALR, OP_LOAD, OP_CALRI, OP_CALRR : reg_wen = 1'b1;
      OP_BRANCH, OP_STORE                                            : reg_wen = 1'b0;
      default                                                        : reg_wen = 1'b0;
    endcase
  end */
  /* always_comb begin
    case (opcode)
      OP_LUI, OP_AUIPC, OP_JAL, OP_JALR, OP_CALRI, OP_CALRR: reg_wdata = alu_val;
      OP_LOAD: reg_wdata = mem_rdata;
      default: reg_wdata = alu_val;
    endcase
  end */

  // -------------------- 内存读写 --------------------
  assign mem_rfunc = funct;
  assign mem_raddr = alu_val;
  // mem_rdata mem模块读取部分看作组合逻辑

  assign mem_wen = (opcode == OP_STORE);
  assign mem_wfunc = funct;
  assign mem_waddr = alu_val;
  assign mem_wdata = src2;

  // -------------------- 控制跳转 --------------------
  // TODO

endmodule
