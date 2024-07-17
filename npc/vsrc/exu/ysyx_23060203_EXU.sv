module ysyx_23060203_EXU (
  input clock, reset,

  // 跳转输出
  output reg jump_flush, // 分支预测错误，需要冲刷流水线
  output [31:0] jump_dnpc,

  // fence.i
  output fencei,

  // 访存AXI接口
  axi_if.out mem_r,
  axi_if.out mem_w,

  // GPR forwarding
  output [4:0] exu_rd,
  output [31:0] exu_gpr_wdata,
  // 将要修改的CSR地址
  output [11:0] exu_csr_waddr,

  // 上游IDU输入
  output in_ready,
  input in_valid,
  input [31:0] in_pc,
  input [31:0] in_val_a,
  input [31:0] in_val_b,
  input [31:0] in_val_c,
  input        in_alu_src,
  input [2:0]  in_alu_funct,
  input        in_alu_sw,
  input [4:0]  in_rd,
  input        in_rd_src,
  input [3:0]  in_ls,
  input [2:0]  in_goto,
  input [1:0]  in_csrw,
  input        in_fencei,

  // 下游WBU输出
  input out_ready,
  output out_valid,
  output [4:0] out_gpr_waddr,
  output [31:0] out_gpr_wdata,
  output out_csr_wen,
  output [11:0] out_csr_waddr,
  output [31:0] out_csr_wdata

  `ifndef SYNTHESIS
    ,
    output [31:0] out_pc,
    input [31:0] in_inst,
    output [31:0] out_inst,
    output [31:0] out_dnpc
  `endif
);

  reg valid;
  reg [31:0] pc;
  reg [31:0] val_a, val_b, val_c;
  reg        alu_src;
  reg [2:0]  alu_funct;
  reg        alu_sw;
  reg [4:0]  rd;
  reg        rd_src;
  reg [3:0]  ls;
  reg [2:0]  goto;
  reg [1:0]  csrw;
  `ifndef SYNTHESIS
    reg [31:0] inst;
  `endif

  `ifndef SYNTHESIS
    assign out_pc = pc;
    assign out_inst = inst;
  `endif

  reg fencei_r;

  always @(posedge clock) if (reset) begin
    valid <= 0;
  end else begin
    if (in_valid & in_ready) begin
      valid <= 1;
      pc <= in_pc;
      val_a <= in_val_a;
      val_b <= in_val_b;
      val_c <= in_val_c;
      alu_src <= in_alu_src;
      alu_funct <= in_alu_funct;
      alu_sw <= in_alu_sw;
      rd <= in_rd;
      rd_src <= in_rd_src;
      ls <= in_ls;
      goto <= in_goto;
      csrw <= in_csrw;
      fencei_r <= in_fencei;
      `ifndef SYNTHESIS
        inst <= in_inst;
      `endif
    end else if (out_ready & out_valid) begin
      valid <= 0;
    end
  end

  assign in_ready = lsu_in_ready;
  assign out_valid = valid & exe_done;

  reg exe_done;
  always_comb begin
    exe_done = 1;
    if (ls[3]) exe_done = lsu_out_valid;
  end

  // -------------------- ALU --------------------
  wire [31:0] alu_a = alu_src ? pc : val_a;
  wire [31:0] alu_b = val_b;
  wire [31:0] alu_val;
  ysyx_23060203_ALU ALU (
    .alu_a(alu_a), .alu_b(alu_b),
    .funct(alu_funct), .sw(alu_sw),
    .val(alu_val)
  );

  // -------------------- LSU --------------------
  wire lsu_in_valid = in_valid & (|in_ls);
  wire lsu_in_ready, lsu_out_valid;
  wire [31:0] lsu_out_rdata;
  ysyx_23060203_LSU LSU (
    .clock(clock), .reset(reset),
    .mem_r(mem_r), .mem_w(mem_w),
    .in_ready(lsu_in_ready), .in_valid(lsu_in_valid),
    .in_ls(in_ls), .ls(ls), .alu_val(alu_val), .val_c(val_c),
    .out_ready(out_ready), .out_valid(lsu_out_valid),
    .out_rdata(lsu_out_rdata)
  );

  // -------------------- 跳转 --------------------
  wire alu_val_any = |alu_val;
  reg jump_en;
  always_comb begin
    case (goto)
      3'b000 : jump_en = 0;
      3'b100 : jump_en = alu_val_any;
      3'b101 : jump_en = ~alu_val_any;
      default: jump_en = 1;
    endcase
  end

  reg [31:0] dnpc_a, dnpc_b;
  always_comb begin
    case (goto)
      3'b010, 3'b011 : dnpc_a = val_a;
      default        : dnpc_a = pc;
    endcase

    case (goto)
      3'b011  : dnpc_b = 32'h0;
      default : dnpc_b = val_c;
    endcase
  end
  wire [31:0] dnpc_c = dnpc_a + (jump_en ? dnpc_b : 32'h4);

  // TEMP: 当前分支预测是btfnt(仅branch指令)
  assign jump_flush = valid & (jump_en ^ (goto[2] & val_c[31]));
  assign jump_dnpc = {dnpc_c[31:1], 1'b0};

  `ifndef SYNTHESIS
    assign out_dnpc = jump_dnpc;
  `endif

  // -------------------- fence.i --------------------
  assign fencei = valid & fencei_r;

  // -------------------- GPR写回 --------------------
  assign out_gpr_waddr = rd;
  assign out_gpr_wdata = ls[3] ? (
    lsu_out_rdata
  ) : (
    rd_src ? val_a : alu_val
  );

  assign exu_rd = rd & {5{valid}};
  assign exu_gpr_wdata = out_gpr_wdata;

  // -------------------- CSR写回 --------------------
  assign out_csr_wen = |csrw;
  assign out_csr_waddr = &csrw ? 12'h0 : val_c[11:0];
  assign out_csr_wdata = csrw[1] ? val_b : alu_val;
  // ebreak被标记为对0号CSR的有效写入操作

  assign exu_csr_waddr = out_csr_waddr & {12{valid & out_csr_wen}};

  // -------------------- 性能计数器 --------------------
`ifndef SYNTHESIS
  always @(posedge clock) if (~reset) begin
    if (out_ready & out_valid) begin
      perf_event(PERF_EXU_INST);
    end
    if (jump_flush) begin
      perf_event(PERF_EXU_FLUSH);
    end
    if (~valid) begin
      perf_event(PERF_EXU_IDLE);
    end
  end
`endif

endmodule
