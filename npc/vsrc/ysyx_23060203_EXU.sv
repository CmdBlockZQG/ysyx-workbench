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
  output reg [4:0] gpr_waddr,
  output reg [31:0] gpr_wdata,

  // CSR写
  output reg csr_wen1, // 写入使能
  output reg [11:0] csr_waddr1, // 写入地址
  output reg [31:0] csr_wdata1, // 写入数据
  output reg csr_wen2, // 写入使能
  output reg [11:0] csr_waddr2, // 写入地址
  output reg [31:0] csr_wdata2, // 写入数据

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
  wire [11:0] id_csr_waddr1 = (|funct) ? csr_addr : CSR_MEPC; // ecall向mepc写入pc
  wire [31:0] id_csr_wdata1 = alu_val;

  wire id_csr_wen2 = ecall; // ecall
  wire [11:0] id_csr_waddr2 = CSR_MCAUSE;
  wire [31:0] id_csr_wdata2 = 32'd11; // 11表示sys call

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

  // -------------------- 时序逻辑 --------------------
  always @(posedge clk) begin
    if (~rstn) begin
      id_in.ready <= 1;

      mem_rreq.valid <= 0;
      mem_rres.ready <= 0;
      mem_wreq.valid <= 0;
      mem_wres.ready <= 0;

      load_flag <= 0;
      store_flag <= 0;
      mem_res_flag <= 0;
    end
  end

  // 暂存寄存器
  reg [31:0] alu_val_reg, src2_reg;
  reg [2:0] funct_reg;
  reg [4:0] opcode_reg, rd_reg;
  // 每个步骤的处理状态寄存器
  reg load_flag, store_flag, mem_res_flag;
  // 辅助组合
  wire mem_r_res_hs = mem_rres.valid & mem_rres.ready;
  wire mem_w_res_hs = mem_wres.valid & mem_wres.ready;
  wire id_ls = (opcode == OP_LOAD) | (opcode == OP_STORE);

  always @(posedge clk) begin if (rstn) begin
    if (id_in.ready & id_in.valid) begin
      alu_val_reg <= alu_val;
      src2_reg <= src2;
      funct_reg <= funct;
      opcode_reg <= opcode;
      rd_reg <= rd;

      if (id_gpr_wen & opcode != OP_LOAD) begin
        gpr_wen <= 1;
        gpr_waddr <= rd;
        gpr_wdata <= id_gpr_wdata;
      end

      csr_wen1 <= id_csr_wen1;
      csr_waddr1 <= id_csr_waddr1;
      csr_wdata1 <= id_csr_wdata1;
      csr_wen2 <= id_csr_wen2;
      csr_waddr2 <= id_csr_waddr2;
      csr_wdata2 <= id_csr_wdata2;

      id_in.ready <= ~id_ls;
`ifndef SYNTHESIS
      if (~id_ls) perf_event(PERF_EXU_READY);
`endif
    end

    if (~id_in.ready | id_in.valid) begin
      // 发送访存请求
      case (id_in.valid ? opcode : opcode_reg)
        OP_LOAD:
          if (~mem_rreq.valid & ~load_flag) begin
            mem_rreq.valid <= 1;
            mem_raddr <= alu_val;
            mem_rfunc <= funct;
            load_flag <= 1;
          end
        OP_STORE:
          if (~mem_wreq.valid & ~store_flag) begin
            mem_wreq.valid <= 1;
            mem_wfunc <= id_in.valid ? funct : funct_reg;
            mem_waddr <= id_in.valid ? alu_val : alu_val_reg;
            mem_wdata <= id_in.valid ? src2 : src2_reg;
            store_flag <= 1;
          end
        default: ;
      endcase

      // 确认lsu收到读内存请求
      if (mem_rreq.valid & mem_rreq.ready) begin
        mem_rreq.valid <= 0;
        mem_rres.ready <= 1;
      end
      // 确认lsu收到写内存请求
      if (mem_wreq.valid & mem_wreq.ready) begin
        mem_wreq.valid <= 0;
        mem_wres.ready <= 1;
      end

      // 访存请求回复
      if (mem_r_res_hs) begin
        mem_rres.ready <= 0;
        gpr_wen <= 1;
        gpr_waddr <= rd_reg;
        gpr_wdata <= mem_rdata;
        id_in.ready <= 1;
        load_flag <= 0;
`ifndef SYNTHESIS
        perf_event(PERF_EXU_READY);
`endif
      end
      if (mem_w_res_hs) begin
        mem_wres.ready <= 0;
        id_in.ready <= 1;
        store_flag <= 0;
`ifndef SYNTHESIS
        perf_event(PERF_EXU_READY);
`endif
      end
    end

    // 确认GPR写入
    // 因为不可能连续两个周期写，所以这个是对的
    if (gpr_wen) begin
      gpr_wen <= 0;
    end
    // CSR同理
    if (csr_wen1) begin
      csr_wen1 <= 0;
    end
    if (csr_wen2) begin
      csr_wen2 <= 0;
    end
  end end

  // -------------------- 性能计数器 --------------------
`ifndef SYNTHESIS

  wire perf_id_hs = id_in.ready & id_in.valid;

  reg [4:0] perf_opcode_reg;
  wire [4:0] perf_opcode = perf_id_hs ? opcode : perf_opcode_reg;

  reg [2:0] perf_funct_reg;
  wire [2:0] perf_funct = perf_id_hs ? funct : perf_funct_reg;

  always @(posedge clk) if (rstn) begin
    if (perf_id_hs) begin
      perf_opcode_reg <= opcode;
      perf_funct_reg <= funct;
    end

    if (perf_id_hs | ~id_in.ready) begin
      case (perf_opcode)
        OP_LUI, OP_AUIPC: perf_event(PERF_EXU_UPIMM);
        OP_JAL, OP_JALR: perf_event(PERF_EXU_JUMP);
        OP_BRANCH: perf_event(PERF_EXU_BRANCH);
        OP_LOAD: perf_event(PERF_EXU_LOAD);
        OP_STORE: perf_event(PERF_EXU_STORE);
        OP_CALRI: perf_event(PERF_EXU_CALRI);
        OP_CALRR: perf_event(PERF_EXU_CALRR);
        OP_SYS: begin
          if (perf_funct == 3'b000) perf_event(PERF_EXU_SYS);
          else perf_event(PERF_EXU_CSR);
        end
        default: begin end // TEMP: 暂时无报告未知指令的逻辑
      endcase
    end
  end
`endif
endmodule
