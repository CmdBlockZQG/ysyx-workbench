module ysyx_23060203_EXU (
  // 组合逻辑,无时钟和复位

  // 连接IDU输出
  input [4:0] opcode,
  input [2:0] funct,
  input [4:0] rd,
  input [31:0] src1,
  input [31:0] src2,
  input [31:0] imm,
  input [31:0] csr,

  // 连接ALU输出
  input [31:0] alu_val,

  // 寄存器写
  output reg reg_wen,
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

  // 连接CSR写端口
  output csr_wen1, // 写入使能
  output [11:0] csr_waddr1, // 写入地址
  output [31:0] csr_wdata1, // 写入数据
  output csr_wen2, // 写入使能
  output [11:0] csr_waddr2, // 写入地址
  output [31:0] csr_wdata2, // 写入数据

  // 连接PC模块，控制跳转
  output reg [31:0] pc_inc,
  output pc_ovrd,
  output [31:0] pc_ovrd_addr
);
  `include "params/opcode.v"
  `include "params/branch.v"
  `include "params/csr.v"

  // -------------------- 寄存器写 --------------------
  // 寄存器写端口使能
  // 只有这么两种指令不写寄存器，但是这样做会导致复位非法指令通过测试
  // assign reg_wen = (opcode != OP_BRANCH) & (opcode != OP_STORE);
  // 所以采用下面的写法，过滤非法指令
  always_comb begin
    case (opcode)
      OP_LUI, OP_AUIPC, OP_JAL, OP_JALR,
             OP_LOAD, OP_CALRI, OP_CALRR : reg_wen = 1'b1;
      OP_SYS                             : reg_wen = |funct; // 只有funct不为0的有csr读取
      OP_BRANCH, OP_STORE                : reg_wen = 1'b0;
      default                            : reg_wen = 1'b0;
    endcase
  end
  assign reg_waddr = rd;
  always_comb begin
    case (opcode)
      OP_LUI, OP_AUIPC, OP_JAL, OP_JALR,
                      OP_CALRI, OP_CALRR : reg_wdata = alu_val;
      OP_LOAD                            : reg_wdata = mem_rdata;
      OP_SYS                             : reg_wdata = csr;
      default                            : reg_wdata = alu_val;
    endcase
  end

  // -------------------- 内存读写 --------------------
  assign mem_ren = (opcode == OP_LOAD);
  assign mem_rfunc = funct;
  assign mem_raddr = alu_val;
  // mem_rdata mem模块读取部分（暂时？）看作组合逻辑

  assign mem_wen = (opcode == OP_STORE);
  assign mem_wfunc = funct;
  assign mem_waddr = alu_val;
  assign mem_wdata = src2;

  // -------------------- CSR写 --------------------
  wire [11:0] csr_addr = imm[11:0];
  wire ecall = (opcode == OP_SYS) & (csr_addr == 12'b0);
  // csr操作指令funct不是全0，ecall的csr地址是全0
  assign csr_wen1 = (opcode == OP_SYS) & ((|funct) | (csr_addr == 12'b0));
  assign csr_waddr1 = (|funct) ? csr_addr : CSR_MEPC; // ecall向mepc写入pc
  assign csr_wdata1 = alu_val;

  assign csr_wen2 = ecall; // ecall
  assign csr_waddr2 = CSR_MCAUSE;
  assign csr_wdata2 = 32'd11; // 11表示sys call

  // -------------------- 控制跳转 --------------------
  // 改动PC和跳转部分设计时务必检查复位后pc值的正确性
  wire csr_jump = (opcode == OP_SYS) & (funct == 3'b0); // 只考虑ecall和mret存在的情况了
  assign pc_ovrd = (opcode == OP_JALR) | csr_jump; // 需要保证在复位和复位释放后第一个时钟上升沿到来之前为0
  assign pc_ovrd_addr = csr_jump ? csr : src1;

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
      OP_JAL, OP_JALR : pc_inc = imm;
      OP_BRANCH       : pc_inc = br_en ? imm : 4;
      OP_SYS          : pc_inc = csr_jump ? 0 : 4;
      default         : pc_inc = 4; // 需要保证在复位和复位释放后第一个时钟上升沿到来之前为4
    endcase
  end
  // TODO: 检查这里综合出来是不是二选一，综合成两级就改成下面：
  // assign pc_inc = (opcode == OP_JAL) \
  //                 | (opcode == OP_JALR) \
  //                 | ((opcode == OP_BRANCH) & br_en) \
  //                 ? imm : 4

endmodule
