module ysyx_23060203_EXU (
  // 组合逻辑,无时钟和复位

  // 连接IDU输出
  input [4:0] opcode,
  input [2:0] funct,
  input [4:0] rd,
  input [11:0] csr,
  input [31:0] src1,
  input [31:0] src2,
  input [31:0] imm,

  // 连接ALU输出
  input [31:0] alu_val,

  // 寄存器写
  output reg_wen,
  output [4:0] reg_waddr,
  output [31:0] reg_wdata,

  // 连接访存模块
  output mem_ren,
  output [2:0] mem_rfunc,
  output [31:0] mem_raddr,
  input [31:0] mem_rdata,
  output mem_wen,
  output [2:0] mem_wfunc,
  output [31:0] mem_waddr,
  output [31:0] mem_wdata,

  // 连接PC模块，控制跳转
  output reg [31:0] pc_inc,
  output pc_ovrd,
  output [31:0] pc_ovrd_addr
);
  `include "params/opcode.v"
  `include "params/branch.v"

  // -------------------- EBREAK HALT --------------------
  `include "dpic.v"
  always_comb begin
    if (opcode == OP_ECALL && csr == 1) begin
      halt();
    end
  end

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
  assign mem_ren = (opcode == OP_LOAD);
  assign mem_rfunc = funct;
  assign mem_raddr = alu_val;
  // mem_rdata mem模块读取部分（暂时？）看作组合逻辑

  assign mem_wen = (opcode == OP_STORE);
  assign mem_wfunc = funct;
  assign mem_waddr = alu_val;
  assign mem_wdata = src2;

  // -------------------- 控制跳转 --------------------
  // 改动PC和跳转部分设计时务必检查复位后pc值的正确性
  assign pc_ovrd = (opcode == OP_JALR); // 需要保证在复位和复位释放后第一个时钟上升沿到来之前为0
  assign pc_ovrd_addr = src1;

  wire alu_zf_n = |alu_val;

  reg br_en; // 分支语句，跳转条件是否满足，注意这个值在opcode不为OP_BRANCH时是无效的
  always_comb begin
    case (funct)
      BR_BEQ          : br_en = ~alu_zf_n;
      BR_BNE          : br_en =  alu_zf_n;
      BR_BLT, BR_BLTU : br_en =  alu_val[0];
      BR_BGE, BR_BGEU : br_en = ~alu_val[0];
      default         : br_en = 0;
    endcase
  end

  // pc_inc
  always_comb begin
    case (opcode)
      OP_JAL, OP_JALR: pc_inc = imm;
      OP_BRANCH: pc_inc = br_en ? imm : 4;
      default: pc_inc = 4; // 需要保证在复位和复位释放后第一个时钟上升沿到来之前为4
    endcase
  end
  // TODO: 检查这里综合出来是不是二选一，综合成两级就改成下面：
  // assign pc_inc = (opcode == OP_JAL) \
  //                 | (opcode == OP_JALR) \
  //                 | ((opcode == OP_BRANCH) & br_en) \
  //                 ? imm : 4

endmodule
