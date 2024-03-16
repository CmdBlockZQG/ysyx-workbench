`include "interface/decouple.sv"

module ysyx_23060203_EXU (
  input rstn, clk,

  // 连接IDU输出
  input [31:0] pc,
  input [4:0] opcode,
  input [2:0] funct,
  input [4:0] rd,
  input [31:0] src1,
  input [31:0] src2,
  input [31:0] imm,
  input [31:0] csr,
  input [31:0] alu_a,
  input [31:0] alu_b,
  input [2:0] alu_funct,
  input alu_funcs,
  decouple_if.in id_in,

  // 连接PC模块，控制跳转
  output [31:0] npc,

  // 寄存器写
  output reg gpr_wen,
  output [4:0] gpr_waddr,
  output [31:0] gpr_wdata,

  // CSR写
  output reg csr_wen1, // 写入使能
  output [11:0] csr_waddr1, // 写入地址
  output [31:0] csr_wdata1, // 写入数据
  output reg csr_wen2, // 写入使能
  output [11:0] csr_waddr2, // 写入地址
  output [31:0] csr_wdata2, // 写入数据

  // 连接访存模块
  // 访存读请求
  output reg [31:0] mem_raddr,
  output reg [2:0] mem_rfunc,
  decouple_if.out mem_rreq,
  // 访存读回复
  input [31:0] mem_rdata,
  decouple_if.in mem_rres,
  // 访存写
  output [2:0] mem_wfunc,
  output [31:0] mem_waddr,
  output [31:0] mem_wdata,
  decouple_if.out mem_wreq,
  decouple_if.in mem_wres
);
  `include "params/opcode.sv"
  `include "params/branch.sv"
  `include "params/csr.sv"

  // -------------------- ALU --------------------
  wire [31:0] alu_val;
  ysyx_23060203_ALU ALU (
    .alu_a(alu_a),
    .alu_b(alu_b),
    .funct(alu_funct),
    .funcs(alu_funcs),
    .val(alu_val)
  );

  // -------------------- 寄存器写 --------------------
  reg id_gpr_wen;
  reg [31:0] id_gpr_wdata;
  always_comb begin
    case (opcode)
      OP_LUI, OP_AUIPC, OP_JAL, OP_JALR,
             OP_LOAD, OP_CALRI, OP_CALRR : id_gpr_wen = 1'b1;
      OP_SYS                             : id_gpr_wen = |funct; // 只有funct不为0的有csr读取
      OP_BRANCH, OP_STORE                : id_gpr_wen = 1'b0;
      default                            : id_gpr_wen = 1'b0;
    endcase
  end
  always_comb begin
    case (opcode)
      OP_LUI, OP_AUIPC, OP_JAL, OP_JALR,
                      OP_CALRI, OP_CALRR : id_gpr_wdata = alu_val;
      OP_SYS                             : id_gpr_wdata = csr;
      default                            : id_gpr_wdata = alu_val; // LOAD指令单独处理，不使用这里的结果
    endcase
  end

  // -------------------- CSR写 --------------------
  wire [11:0] csr_addr = imm[11:0];
  wire ecall = (opcode == OP_SYS) & (csr_addr == 12'b0);
  // csr操作指令funct不是全0，ecall的csr地址是全0
  wire id_csr_wen1 = (opcode == OP_SYS) & ((|funct) | (csr_addr == 12'b0));
  assign csr_waddr1 = (|funct) ? csr_addr : CSR_MEPC; // ecall向mepc写入pc
  assign csr_wdata1 = alu_val;

  wire id_csr_wen2 = ecall; // ecall
  assign csr_waddr2 = CSR_MCAUSE;
  assign csr_wdata2 = 32'd11; // 11表示sys call

  // -------------------- 控制跳转 --------------------
  reg [31:0] pc_inc;
  wire pc_ovrd;
  wire [31:0] pc_ovrd_addr;
  wire csr_jump = (opcode == OP_SYS) & (funct == 3'b0); // 只考虑ecall和mret存在的情况了
  assign pc_ovrd = (opcode == OP_JALR) | csr_jump;
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
  always_comb begin
    case (opcode)
      OP_JAL, OP_JALR : pc_inc = imm;
      OP_BRANCH       : pc_inc = br_en ? imm : 4;
      OP_SYS          : pc_inc = csr_jump ? 0 : 4;
      default         : pc_inc = 4; // 需要保证在复位和复位释放后第一个时钟上升沿到来之前为4
    endcase
  end
  wire [31:0] npc_base = pc_ovrd ? pc_ovrd_addr : pc;
  wire [31:0] npc_orig = npc_base + pc_inc;
  assign npc = {npc_orig[31:1], 1'b0};

  // -------------------- 访存控制 --------------------
  // 组合逻辑
  wire id_load = (opcode == OP_LOAD);
  wire id_store = (opcode == OP_STORE);
  wire id_ls = id_load | id_store;
  wire mem_r_res_hs = mem_rres.valid & mem_rres.ready;
  wire mem_w_res_hs = mem_wres.valid & mem_wres.ready;

  reg mem_res_flag;
  reg load_complete;
  always @(posedge clk) begin
    if (~rstn) begin
      load_complete <= 0;
    end
  end

  assign id_in.ready = ~id_ls | ~mem_res_flag;
  always @(posedge clk) begin
    if (id_in.ready & id_in.valid) begin
      mem_res_flag <= id_ls;
    end
  end

  assign mem_raddr = alu_val;
  assign mem_rfunc = funct;
  assign mem_rreq.valid = id_load;

  assign mem_waddr = alu_val;
  assign mem_wfunc = funct;
  assign mem_wdata = src2;
  assign mem_wreq.valid = id_store;

  always @(posedge clk) begin
    if (mem_r_res_hs) begin
      gpr_wen <= 1;
      gpr_waddr <= rd;
      gpr_wdata <= mem_rdata;
      load_complete <= 1;
    end
    if (mem_w_res_hs) begin
      mem_res_flag <= 0;
    end
    if (load_complete) begin
      mem_res_flag <= 0;
      load_complete <= 0;
    end
  end
endmodule
