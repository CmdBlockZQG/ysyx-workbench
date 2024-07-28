module ysyx_23060203_IFU (
  input clock, reset,

  input flush,
  input [31:0] dnpc,
  input fencei,

  input out_ready,
  output out_valid,
  output [31:0] out_pc,
  output [31:0] out_inst,

  axi_if.out mem_r
);

  wire hit;
  wire [31:0] cache_addr, cache_inst;
  ysyx_23060203_ICache ICache (
    .clock(clock), .reset(reset),
    .fencei(fencei),
    .addr(cache_addr), .hit(hit), .inst(cache_inst),
    .mem_r(mem_r)
  );

  typedef enum logic {
    ST_HOLD = 1'b1,
    ST_WAIT = 1'b0
  } state_t;
  wire st_hold = state;
  wire st_wait = ~state;

  state_t state, state_next;
  reg [31:0] pc, pc_next;
  reg [31:0] inst, inst_next;
  reg flush_r, flush_r_next;
  reg [31:0] dnpc_r, dnpc_r_next;

  wire [31:0] imm_b = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
  wire [31:0] pc_incr = (inst[6:2] == 5'b11000) & inst[31] ? imm_b : 32'h4;

  always @(posedge clock) begin
    if (reset) begin
      state <= ST_WAIT;
      `ifdef YSYXSOC
        // soc中从flash开始取指
        pc <= 32'h30000000;
      `else
        // 仿真从0x80000000开始取指
        pc <= 32'h80000000;
      `endif
      flush_r <= 0;
    end else begin
      state <= state_next;
      pc <= pc_next;
      inst <= inst_next;
      flush_r <= flush_r_next;
      dnpc_r <= dnpc_r_next;
    end
  end

  always_comb begin
    state_next = state;
    pc_next = pc;
    inst_next = inst;
    flush_r_next = flush_r;
    dnpc_r_next = dnpc_r;

    if (st_hold) begin
      if ((out_valid & out_ready) | (flush | flush_r)) begin
        pc_next = flush ? dnpc : (
          flush_r ? dnpc_r : pc + pc_incr
        );
        flush_r_next = 0;
        if (hit) begin
          inst_next = cache_inst;
        end else begin
          state_next = ST_WAIT;
        end
      end
    end else if (st_wait) begin
      if (flush) begin
        flush_r_next = 1;
        dnpc_r_next = dnpc;
      end
      if (hit) begin
        state_next = ST_HOLD;
        inst_next = cache_inst;
      end
    end
  end

  assign cache_addr = st_hold ? pc_next : pc;
  assign out_valid = st_hold & ~flush & ~flush_r;
  assign out_pc = pc;
  assign out_inst = inst;

  // -------------------- 性能计数器 --------------------
`ifndef SYNTHESIS
  always @(posedge clock) if (~reset) begin
    if (st_hold) begin
      perf_event(PERF_IFU_HOLD);
    end
    if (st_wait) begin
      perf_event(PERF_IFU_WAIT);
    end
    if (out_valid & out_ready) begin
      perf_event(PERF_IFU_INST);
    end
  end
`endif

endmodule
