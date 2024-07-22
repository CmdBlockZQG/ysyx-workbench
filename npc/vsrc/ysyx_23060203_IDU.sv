module ysyx_23060203_IDU (
  input clock, reset,

  // GPR
  output [4:0] gpr_raddr1,
  input [31:0] gpr_rdata1,
  output [4:0] gpr_raddr2,
  input [31:0] gpr_rdata2,

  // CSR
  output [11:0] csr_raddr,
  input [31:0] csr_rdata,

  // 冲刷信号
  input flush,

  // GPR旁路
  input [4:0] exu_rd,
  input [31:0] exu_gpr_wdata,

  // EXU将要写入但还没写入的CSR
  input [11:0] exu_csr_waddr,

  // 上游IFU输入
  output in_ready,
  input in_valid,
  input [31:0] in_pc,
  input [31:0] in_inst,

  // 下游EXU输出
  input out_ready,
  output out_valid,
  output     [31:0] out_pc,
  output reg [31:0] out_val_a,
  output reg [31:0] out_val_b,
  output reg [31:0] out_val_c,
  output reg        out_alu_src,
  output reg [2:0]  out_alu_funct,
  output reg        out_alu_sw,
  // output reg        out_mul,
  output reg [4:0]  out_rd,
  output reg        out_rd_src,
  output reg [3:0]  out_ls,
  output reg [2:0]  out_goto,
  output reg [1:0]  out_csrw,
  output out_fencei

  `ifndef SYNTHESIS
    ,
    output reg [31:0] out_inst
  `endif
);

  `include "def/opcode.sv"
  `include "def/csr.sv"
  `include "def/alu.sv"
  `include "def/branch.sv"

  typedef enum logic {
    ST_IDLE,
    ST_HOLD
  } state_t;
  wire st_idle = state == ST_IDLE;
  wire st_hold = state == ST_HOLD;

  state_t state, state_next;
  reg [31:0] pc, pc_next;
  reg [31:0] inst, inst_next;

  always @(posedge clock) begin
    if (reset) begin
      state <= ST_IDLE;
    end else begin
      state <= state_next;
      pc <= pc_next;
      inst <= inst_next;
    end
  end

  assign in_ready = st_idle | (out_ready & out_valid) | flush;

  always_comb begin
    state_next = state;
    pc_next = pc;
    inst_next = inst;

    if (in_ready & in_valid) begin // input
      state_next = ST_HOLD;
      pc_next = in_pc;
      inst_next = in_inst;
    end

    case (state)
      ST_IDLE: begin
        if (in_valid) ; // input
      end
      ST_HOLD: begin
        if ((out_valid & out_ready) | flush) begin
          if (in_valid) begin
            ; // input
          end else begin
            state_next = ST_IDLE;
          end
        end
      end
      default: ;
    endcase
  end

  assign out_pc = pc;
  `ifndef SYNTHESIS
    assign out_inst = inst;
  `endif

  // -------------------- 指令 --------------------
  wire [4:0] opcode = inst[6:2];
  wire [2:0] funct3 = inst[14:12];
  wire [6:0] funct7 = inst[31:25];
  wire [11:0] funct12 = inst[31:20];

  // -------------------- 立即数 --------------------
  wire [31:0] imm_i, imm_s, imm_b, imm_u, imm_j, imm_z;
  assign imm_i = {{20{inst[31]}}, inst[31:20]};
  assign imm_s = {{20{inst[31]}}, inst[31:25], inst[11:7]};
  assign imm_b = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
  assign imm_u = {inst[31:12], 12'b0};
  assign imm_j = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
  assign imm_z = {27'b0, inst[19:15]};

  // -------------------- 通用寄存器 --------------------
  wire [4:0] rd = inst[11:7], rs1 = inst[19:15], rs2 = inst[24:20];
  assign gpr_raddr1 = rs1;
  assign gpr_raddr2 = rs2;
  wire [31:0] src1 = ((exu_rd == rs1) & (|rs1)) ? exu_gpr_wdata : gpr_rdata1;
  wire [31:0] src2 = ((exu_rd == rs2) & (|rs2)) ? exu_gpr_wdata : gpr_rdata2;

  // -------------------- SYS --------------------
  // TEMP: 除了zicsr外，只支持ecall mret ebreak

  wire zicsr = |funct3; // SYS指令中，仅zicsr指令d funct3不为0
  wire ebreak = funct12[1:0] == 2'b01;

  // zicsr指令读取的csr由指令csr字段指示
  wire [11:0] csr = inst[31:20];
  // 指令隐含的csr读取
  wire [11:0] op_csr = funct12[1] ? CSR_MEPC : CSR_MTVEC;

  // 读取csr值
  assign csr_raddr = zicsr ? csr : op_csr;
  wire [31:0] src_csr = csr_rdata;

  wire [31:0] sys_val_b = zicsr ? (
    funct3[2] ? imm_z : src1 // 参见zicsr指令funct3值
  ) : pc;

  wire [31:0] sys_val_c = zicsr ? {20'h0, csr} : {20'h0, CSR_MEPC};

  reg [2:0] sys_alu_funct;
  always_comb begin
    case (funct3)
      CSRF_RS, CSRF_RSI: sys_alu_funct = ALU_OR;
      CSRF_RC, CSRF_RCI: sys_alu_funct = ALU_AND;
      default          : sys_alu_funct = ALU_ADD;
    endcase
  end

  wire need_csr = (opcode == OP_SYS) & ~ebreak;
  wire csr_raw = need_csr & (csr_raddr == exu_csr_waddr);

  // -------------------- 分支 --------------------
  reg [2:0] branch_alu_funct;
  // 分支指令时alu的功能选择，在opcode不为OP_BRANCH时无效
  always_comb begin
    case (funct3)
      BR_BLT, BR_BGE   : branch_alu_funct = ALU_LTS;
      BR_BLTU, BR_BGEU : branch_alu_funct = ALU_LTU;
      BR_BEQ, BR_BNE   : branch_alu_funct = ALU_XOR;
      default          : branch_alu_funct = ALU_ADD;
    endcase
  end

  // -------------------- 选数 --------------------
  always_comb begin
    case (opcode)
      OP_JALR, OP_BRANCH, OP_LOAD,
           OP_STORE, OP_RI, OP_RR  : out_val_a = src1;
      OP_SYS                       : out_val_a = src_csr;
      default                      : out_val_a = 32'h0;
    endcase

    case (opcode)
      OP_LUI, OP_AUIPC : out_val_b = imm_u;
      OP_JAL, OP_JALR  : out_val_b = 32'h4;
      OP_BRANCH, OP_RR : out_val_b = src2;
      OP_LOAD, OP_RI   : out_val_b = imm_i;
      OP_STORE         : out_val_b = imm_s;
      OP_SYS           : out_val_b = sys_val_b;
      default          : out_val_b = 32'h0;
    endcase

    case (opcode)
      OP_JAL    : out_val_c = imm_j;
      OP_JALR   : out_val_c = imm_i;
      OP_BRANCH : out_val_c = imm_b;
      OP_STORE  : out_val_c = src2;
      OP_SYS    : out_val_c = sys_val_c;
      default   : out_val_c = 32'h0;
    endcase
  end

  // -------------------- 控制信号 --------------------

  assign out_valid = st_hold & ~flush & ~csr_raw;
  assign out_fencei = opcode == OP_FENCEI;

  // alu_src ALU的两个运算数
  // 0: val_a, val_b
  // 1: pc, val_b
  always_comb begin
    case (opcode)
      OP_AUIPC, OP_JAL, OP_JALR : out_alu_src = 1;
      default: out_alu_src = 0;
    endcase
  end

  // alu_funct ALU模式选择
  // 见def/alu.sv
  always_comb begin
    case (opcode)
      OP_BRANCH    : out_alu_funct = branch_alu_funct;
      OP_RI, OP_RR : out_alu_funct = funct3;
      OP_SYS       : out_alu_funct = sys_alu_funct;
      default      : out_alu_funct = ALU_ADD;
    endcase
  end

  // alu_sw ALU符号切换
  always_comb begin
    case (opcode)
      OP_RR   : out_alu_sw = funct7[5];
      OP_RI   : out_alu_sw = (funct3 == ALU_SHR) & funct7[5];
      OP_SYS  : out_alu_sw = &funct3[1:0];
      default : out_alu_sw = 1'b0;
    endcase
  end

  // mul 是否为乘除法指令
  // 若是，则alu_funct传递乘除法模式
  // always_comb begin
  //   out_mul = (opcode == OP_RR) & funct7[0];
  // end

  // rd 目标寄存器
  // 0表示不写入寄存器
  always_comb begin
    case (opcode)
      OP_BRANCH, OP_STORE : out_rd = 5'b0;
      default             : out_rd = rd;
      // ecall, mret, ebreak, fence.i也不写入寄存器，但它们的rd字段都是0
    endcase
  end

  // rd_src 目标寄存器写入值的来源
  // 0: ALU
  // 1: val_a 用于支持zicsr指令
  // 当执行LOAD指令时（可从ls得知），该值无效，寄存器写入内存读取结果
  // 当执行乘除法指令时（可从mul得知），该值无效，寄存器写入乘除法结果
  always_comb begin
    out_rd_src = (opcode == OP_SYS);
  end

  // ls[3:0] 内存操作类型
  // 4'b0: 无内存操作
  // ls[3]: gpr_wen/mem_ren/~mem_wen
  // ls[2]: sext, 1表示符号拓展（只对load有意义）
  // ls[1:0]: size, 00, 01, 10, 11分别表示b, h, w, d
  always_comb begin
    case (opcode)
      OP_LOAD  : out_ls = {1'b1, ~funct3[2], funct3[1:0]};
      OP_STORE : out_ls = {2'b01, funct3[1:0]};
      default  : out_ls = 4'b0;
    endcase
  end

  // goto 跳转目标地址类型
  // 000: 不跳转
  // 001: pc+val_c 无条件 JAL
  // 010: val_a+val_c 无条件 JALR
  // 011: val_a 无条件 ecall,mret
  // 100: pc+val_c ALU输出非0时跳转
  // 101: pc+val_c ALU输出全0时跳转
  always_comb begin
    case (opcode)
      OP_JAL    : out_goto = 3'b001;
      OP_JALR   : out_goto = 3'b010;
      OP_SYS    : out_goto = (zicsr | ebreak) ? 3'b000 : 3'b011;
      OP_BRANCH : out_goto = {2'b10, (funct3[0] & funct3[2]) | ~(|funct3)};
      default   : out_goto = 3'b000;
    endcase
  end

  // csrw CSR写入值来源
  // 00: 不写入CSR
  // 01: ALU
  // 10: val_b
  // 11: ebreak
  always_comb begin
    case (opcode)
      OP_SYS: begin
        out_csrw = zicsr ? (
          (funct3[1:0] == 2'b01) ? 2'b10 : 2'b01
        ) : (
          funct12[0] ? 2'b11 : (
            funct12[1] ? 2'b00 : 2'b10
          )
        );
      end
      default: out_csrw = 2'b00;
    endcase
  end

  // -------------------- 性能计数器 --------------------
`ifndef SYNTHESIS
  always @(posedge clock) if (~reset) begin
    if (st_idle) begin
      perf_event(PERF_IDU_IDLE);
    end
    if (st_hold) begin
      perf_event(PERF_IDU_HOLD);
    end
    if (out_ready & out_valid) begin
      perf_event(PERF_IDU_INST);
      if (opcode == OP_LOAD) perf_event(PERF_IDU_LOAD);
      if (opcode == OP_STORE) perf_event(PERF_IDU_STORE);
      if (opcode == OP_BRANCH) perf_event(PERF_IDU_BRANCH);
      if (opcode == OP_JAL) perf_event(PERF_IDU_JAL);
      if (opcode == OP_JALR) perf_event(PERF_IDU_JALR);
    end
  end
`endif

endmodule
