module ysyx_23060203_IFU (
  input clock, reset,

  axi_if.out mem_r,

  input jump_flush,
  input [31:0] jump_dnpc,
  input cs_flush,
  input [31:0] cs_dnpc,
  input fencei,

  input out_ready,
  output out_valid,
  output reg [31:0] out_pc,
  output reg [31:0] out_inst
);

  wire hit;
  wire [31:0] cache_inst;
  ysyx_23060203_ICache ICache (
    .clock(clock), .reset(reset),
    .fencei(fencei),
    .addr(fetch_pc), .hit(hit), .inst(cache_inst),
    .mem_r(mem_r)
  );

  reg [31:0] out_pc_next, out_inst_next;
  reg out_valid_r, out_valid_r_next;
  reg [31:0] fetch_pc, fetch_pc_next;

  reg flush_r, flush_r_next;

  always @(posedge clock) begin
    if (reset) begin
      out_valid_r <= 0;
      flush_r <= 0;
      `ifdef YSYXSOC
        // soc中从flash开始取指
        fetch_pc <= 32'h30000000;
      `else
        // 仿真从0x80000000开始取指
        fetch_pc <= 32'h80000000;
      `endif
    end else begin
      out_valid_r <= out_valid_r_next;
      out_pc <= out_pc_next;
      out_inst <= out_inst_next;
      fetch_pc <= fetch_pc_next;
      flush_r <= flush_r_next;
      dnpc_r <= dnpc_r_next;
    end
  end

  wire flush = jump_flush | cs_flush;
  wire [31:0] dnpc = cs_flush ? cs_dnpc : jump_dnpc;
  reg [31:0] dnpc_r, dnpc_r_next;

  wire [31:0] imm_b = {{20{cache_inst[31]}}, cache_inst[7],
                       cache_inst[30:25], cache_inst[11:8], 1'b0};
  wire [31:0] pc_incr = (cache_inst[6:2] == 5'b11000) & cache_inst[31] ? imm_b : 32'h4;
  wire [31:0] fetch_pc_pred = fetch_pc + pc_incr;

  // wire flush_w = flush | flush_r;
  // wire out_step_en = ~out_valid_r | out_ready;

  // wire out_valid_r_next = ~flush_w & (hit | ~out_step_en);
  // wire [31:0] out_pc_next = (hit & out_step_en) ? fetch_pc : out_pc;
  // wire [31:0] out_inst_next = (hit & out_step_en) ? cache_inst : out_inst;
  // wire [31:0] fetch_pc_next = ~hit ? fetch_pc :
  //   flush ? dnpc :
  //   flush_r ? dnpc_r :
  //   out_step_en ? fetch_pc_pred : fetch_pc;
  // wire flush_r_next = flush_w & ~hit;
  // wire [31:0] dnpc_r_next = flush ? dnpc : dnpc_r;

  always_comb begin
    out_valid_r_next = out_valid_r;
    out_pc_next = out_pc;
    out_inst_next = out_inst;
    fetch_pc_next = fetch_pc;
    flush_r_next = flush_r;
    dnpc_r_next = dnpc_r;

    if (flush) begin
      out_valid_r_next = 0;
      if (hit) begin
        flush_r_next = 0;
        fetch_pc_next = dnpc;
      end else begin
        flush_r_next = 1;
        dnpc_r_next = dnpc;
      end
    end else if (flush_r) begin
      out_valid_r_next = 0;
      if (hit) begin
        flush_r_next = 0;
        fetch_pc_next = dnpc_r;
      end else begin
        flush_r_next = 1;
      end
    end else if (out_valid_r) begin
      flush_r_next = 0;
      if (out_ready) begin
        if (hit) begin
          out_valid_r_next = 1;
          out_pc_next = fetch_pc;
          out_inst_next = cache_inst;
          fetch_pc_next = fetch_pc_pred;
        end else begin
          out_valid_r_next = 0;
        end
      end else begin
        out_valid_r_next = 1;
      end
    end else begin
      flush_r_next = 0;
      if (hit) begin
        out_valid_r_next = 1;
        out_pc_next = fetch_pc;
        out_inst_next = cache_inst;
        fetch_pc_next = fetch_pc_pred;
      end else begin
        out_valid_r_next = 0;
      end
    end
  end

  assign out_valid = out_valid_r & ~flush;

  // -------------------- 性能计数器 --------------------
`ifndef SYNTHESIS
  always @(posedge clock) if (~reset) begin
    if (out_valid) begin
      perf_event(PERF_IFU_HOLD);
    end else begin
      perf_event(PERF_IFU_WAIT);
    end
    if (hit) begin
      perf_event(PERF_IFU_FETCH_HOLD);
    end else begin
      perf_event(PERF_IFU_FETCH_WAIT);
    end
    if (out_valid & out_ready) begin
      perf_event(PERF_IFU_INST);
    end
  end
`endif

endmodule
