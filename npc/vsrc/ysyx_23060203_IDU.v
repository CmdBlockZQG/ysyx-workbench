module ysyx_23060203_IDU (
  // 组合逻辑,无时钟和复位

  input [31:0] inst, // 指令输入
  input [31:0] pc, // PC输入

  // 连接寄存器文件，译码寄存器
  output [4:0] reg_raddr1,
  input [31:0] reg_rdata1,
  output [4:0] reg_raddr2,
  input [31:0] reg_rdata2,

  // 连接ALU输入
  output reg [31:0] alu_a,
  output reg [31:0] alu_b,
  output [2:0] alu_funct,
  output alu_funcs,

  // 连接EXU输入
  output [4:0] opcode,
  output [2:0] funct,
  output [4:0] rd,
  output [11:0] csr,
  output [31:0] src1,
  output [31:0] src2,
  output [31:0] imm
);
  `include "params/opcode.v"
  `include "params/alu.v"
  `include "params/branch.v"

  // -------------------- 指令译码 --------------------
  assign opcode = inst[6:2];
  assign funct = inst[14:12];
  assign csr = inst[31:20];

  // -------------------- 寄存器译码 --------------------
  wire [4:0] rs1, rs2;

  assign rd = inst[11:7];
  assign rs1 = inst[19:15];
  assign rs2 = inst[24:20];

  // 寄存器文件的读取是组合逻辑
  assign reg_raddr1 = rs1;
  assign src1 = reg_rdata1;
  assign reg_raddr2 = rs2;
  assign src2 = reg_rdata2;

  // -------------------- 立即数译码 --------------------
  wire [31:0] immI, immS, immB, immU, immJ;
  assign immI = {{20{inst[31]}}, inst[31:20]};
  assign immS = {{20{inst[31]}}, inst[31:25], inst[11:7]};
  assign immB = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
  assign immU = {inst[31:12], 12'b0};
  assign immJ = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};

  always_comb begin // 根据指令类型选择立即数
    case (opcode)
      OP_CALRI, OP_LOAD, OP_JALR : imm = immI;
      OP_STORE                   : imm = immS;
      OP_BRANCH                  : imm = immB;
      OP_LUI, OP_AUIPC           : imm = immU;
      OP_JAL                     : imm = immJ;
      default                    : imm = 32'b0; // CALRR 无立即数
    endcase
  end

  // -------------------- ALU连线 --------------------
  always_comb begin // ALU A
    case (opcode)
      OP_LOAD, OP_STORE, OP_CALRI, OP_CALRR, OP_BRANCH : alu_a = src1;
      OP_AUIPC, OP_JAL, OP_JALR                        : alu_a = pc;
      // LUI                                           : alu_a = 32'b0;
      default                                          : alu_a = 32'b0; // 归并到default
    endcase
  end

  always_comb begin // ALU B
    case (opcode)
      OP_CALRR, OP_BRANCH                           : alu_b = src2;
      OP_LUI, OP_AUIPC, OP_LOAD, OP_STORE, OP_CALRI : alu_b = imm;
      // JAL, JALR                                  : alu_b = 32'd4;
      default                                       : alu_b = 32'd4; // 归并到default
    endcase
  end

  reg [2:0] branch_alu_funct;
  always_comb begin // 分支指令时alu的功能选择，在opcode不为OP_BRANCH时无效
    case (funct)
      BR_BLT, BR_BGE   : branch_alu_funct = ALU_LTS;
      BR_BLTU, BR_BGEU : branch_alu_funct = ALU_LTU;
      // BR_BEQ, BR_BNE: branch_alu_funct = ALU_XOR;
      default          : branch_alu_funct = ALU_XOR; // 归并到default
    endcase
  end

  always_comb begin // ALU Function
    case (opcode)
      OP_CALRI, OP_CALRR : alu_funct = funct;
      OP_BRANCH          : alu_funct = branch_alu_funct;
      default            : alu_funct = ALU_ADD;
      // LUI, AUIPC, JAL, JALR, LOAD, STORE 都是直接加法
    endcase
  end

  wire funcs = inst[30]; // 带有功能切换的运算，切换标志位
  // R型运算指令直接取出那个位即可。I型运算指令只有位移指令有。左移指令只能是逻辑，所以这里只考虑了右移。
  wire funcs_en = (opcode == OP_CALRR) | ((opcode == OP_CALRI) & (funct == 3'b101));
  assign alu_funcs = funcs & funcs_en;
endmodule
