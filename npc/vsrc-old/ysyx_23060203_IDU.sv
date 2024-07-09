module ysyx_23060203_IDU (
  input rstn, clk,

  input [31:0] inst, // 指令输入
  input [31:0] pc, // PC输入
  decouple_if.in inst_in,

  // 连接寄存器文件，译码寄存器
  output [4:0] gpr_raddr1,
  input [31:0] gpr_rdata1,
  output [4:0] gpr_raddr2,
  input [31:0] gpr_rdata2,

  // 连接CSR寄存器
  output [11:0] csr_raddr,
  input [31:0] csr_rdata,

  // 连接ALU输入
  output reg [31:0] alu_a,
  output reg [31:0] alu_b,
  output [2:0] alu_funct,
  output alu_funcs,
  // 连接EXU输入
  output [4:0] opcode,
  output [2:0] funct,
  output [4:0] rd,
  output [31:0] src1,
  output [31:0] src2,
  output [31:0] imm,
  output [31:0] csr,
  // 总线
  decouple_if.out id_out
);

  `include "params/opcode.sv"
  `include "params/branch.sv"
  `include "params/csr.sv"

  assign inst_in.ready = id_out.ready;
  assign id_out.valid = inst_in.valid;

  // -------------------- 指令译码 --------------------
  assign opcode = inst[6:2];
  assign funct = inst[14:12];

  // -------------------- 寄存器译码 --------------------
  wire [4:0] rs1, rs2;

  assign rd = inst[11:7];
  assign rs1 = inst[19:15];
  assign rs2 = inst[24:20];

  // 寄存器文件的读取是组合逻辑
  assign gpr_raddr1 = rs1;
  assign src1 = gpr_rdata1;
  assign gpr_raddr2 = rs2;
  assign src2 = gpr_rdata2;

  // -------------------- 立即数译码 --------------------
  wire [31:0] immI, immS, immB, immU, immJ;
  assign immI = {{20{inst[31]}}, inst[31:20]};
  assign immS = {{20{inst[31]}}, inst[31:25], inst[11:7]};
  assign immB = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
  assign immU = {inst[31:12], 12'b0};
  assign immJ = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};

  always_comb begin // 根据指令类型选择立即数
    case (opcode)
      OP_CALRI, OP_LOAD, OP_JALR, OP_SYS : imm = immI;
      OP_STORE                           : imm = immS;
      OP_BRANCH                          : imm = immB;
      OP_LUI, OP_AUIPC                   : imm = immU;
      OP_JAL                             : imm = immJ;
      default                            : imm = 32'b0; // CALRR 无立即数
    endcase
  end

  // -------------------- CSR译码 --------------------
  wire [31:0] zimm = {27'b0, inst[19:15]};
  // ecall需要读取mtvec，mret需要读MEPC
  assign csr_raddr = |funct ? inst[31:20] : (inst[31:20] == 12'b0 ? CSR_MTVEC : CSR_MEPC);
  assign csr = csr_rdata;

  // -------------------- ALU连线 --------------------

  reg [31:0] csr_alu_a;
  always_comb begin // CSR操作时alu操作数A，在opcode不为OP_SYS时无效
    case (funct)
      3'b000            : csr_alu_a = pc;
      CSRF_RW, CSRF_RWI : csr_alu_a = 32'b0;
      default           : csr_alu_a = csr;
    endcase
  end

  always_comb begin // ALU A
    case (opcode)
      OP_LOAD, OP_STORE, OP_CALRI,
              OP_CALRR, OP_BRANCH  : alu_a = src1;
      OP_AUIPC, OP_JAL, OP_JALR    : alu_a = pc;
      OP_SYS                       : alu_a = csr_alu_a;
      // OP_LUI                    : alu_a = 32'b0;
      default                      : alu_a = 32'b0; // 归并到default
    endcase
  end

  always_comb begin // ALU B
    case (opcode)
      OP_CALRR, OP_BRANCH, OP_MISC_MEM : alu_b = src2;
      OP_LUI, OP_AUIPC, OP_LOAD,
              OP_STORE, OP_CALRI       : alu_b = imm;
      OP_SYS                           : alu_b = funct[2] ? zimm : src1; // ecall全是0，src1读取x0也是0
      // OP_JAL, OP_JALR               : alu_b = 32'd4;
      default                          : alu_b = 32'd4; // 归并到default
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

  reg [2:0] csr_alu_funct;
  always_comb begin // CSR操作时alu功能选择，在opcode不为OP_SYS时无效
    case (funct)
      CSRF_RS, CSRF_RSI: csr_alu_funct = ALU_OR;
      CSRF_RC, CSRF_RCI: csr_alu_funct = ALU_AND;
      // CSRF_RW, CSRF_RWI: csr_alu_funct = ALU_XOR;
      // 3'b000的ECALL因为要传递PC，也用XOR
      default          : csr_alu_funct = ALU_XOR; // 归并到default
    endcase
  end

  always_comb begin // ALU Function
    case (opcode)
      OP_CALRI, OP_CALRR : alu_funct = funct;
      OP_BRANCH          : alu_funct = branch_alu_funct;
      OP_SYS             : alu_funct = csr_alu_funct;
      default            : alu_funct = ALU_ADD;
      // LUI, AUIPC, JAL, JALR, LOAD, STORE 都是直接加法
    endcase
  end

  wire funcs = inst[30]; // 带有功能切换的运算，切换标志位
  // R型运算指令直接取出那个位即可。I型运算指令只有位移指令有。左移指令只能是逻辑，所以这里只考虑了右移。
  wire funcs_en = (opcode == OP_CALRR) | ((opcode == OP_CALRI) & (funct == ALU_SHR));
  // csr clear需要取反，csrrc和csrrci的funct低两位都是1
  wire funcs_csr = (opcode == OP_SYS) & funct[1] & funct[0];

  assign alu_funcs = (funcs & funcs_en) | funcs_csr;

  // -------------------- 性能计数器 --------------------
`ifndef SYNTHESIS
  always @(posedge clk) if (rstn & inst_in.valid & inst_in.ready) begin
    case (opcode)
      OP_LUI, OP_AUIPC: perf_event(PERF_IDU_UPIMM);
      OP_JAL, OP_JALR: perf_event(PERF_IDU_JUMP);
      OP_BRANCH: perf_event(PERF_IDU_BRANCH);
      OP_LOAD: perf_event(PERF_IDU_LOAD);
      OP_STORE: perf_event(PERF_IDU_STORE);
      OP_CALRI: perf_event(PERF_IDU_CALRI);
      OP_CALRR: perf_event(PERF_IDU_CALRR);
      OP_SYS: begin
        if (funct == 3'b000) perf_event(PERF_IDU_SYS);
        else perf_event(PERF_IDU_CSR);
      end
      default: begin end // TEMP: 暂时无报告未知指令的逻辑
    endcase
  end
`endif
endmodule
