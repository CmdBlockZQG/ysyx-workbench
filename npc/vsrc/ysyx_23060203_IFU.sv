module ysyx_23060203_IFU (
  input clock, reset,

  input flush,
  input [31:0] dnpc,

  input out_ready,
  output out_valid,
  output [31:0] out_pc,
  output [31:0] out_inst,

  axi_if.out mem_r
);

  // TODO: 状态机IFU,需要流水化
`ifndef YSYXSOC
  typedef enum {
    ST_REQ,  // 发出请求，等待ar通道握手
    ST_RESP, // 等待数据，等待r通道握手
    ST_HOLD  // 保持指令数据，等待下游接收
  } state_t;

  state_t state, state_next;
  reg [31:0] pc, pc_next;
  reg [31:0] inst, inst_next;

  // 请求中途收到flush指令，需要总线事务完成后丢弃读取结果
  reg flush_rdata, flush_rdata_next;

  always @(posedge clock) begin
    if (reset) begin
      state <= ST_REQ;
      inst <= 32'h00000013; // nop
      flush_rdata <= 0;
      `ifdef YSYXSOC
        // soc中从flash开始取指
        pc <= 32'h30000000;
      `else
        // 仿真从0x80000000开始取指
        pc <= 32'h80000000;
      `endif
    end else begin
      state <= state_next;
      pc <= pc_next;
      inst <= inst_next;
      flush_rdata <= flush_rdata_next;
    end
  end

  wire [31:0] imm_b = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
  wire [31:0] pc_incr = (inst[6:2] == 5'b11000) & inst[31] ? imm_b : 32'h4;

  always_comb begin
    state_next = state;
    pc_next = pc;
    inst_next = inst;
    flush_rdata_next = flush_rdata;
    case (state)
      ST_REQ: begin
        if (mem_r.arready & mem_r.arvalid) begin
          state_next = ST_RESP;
          if (flush) begin // 请求已经发出，只能等待取出后丢弃
            flush_rdata_next = 1;
            pc_next = dnpc;
          end
        end else if (flush) begin // 当前请求还没有握手，修正请求地址
          pc_next = dnpc;
        end
      end
      ST_RESP: begin
        if (mem_r.rready & mem_r.rvalid) begin
          if (flush) begin
            state_next = ST_REQ;
            pc_next = dnpc;
          end else if (flush_rdata) begin
            state_next = ST_REQ;
            flush_rdata_next = 0;
          end else begin
            state_next = ST_HOLD;
            inst_next = pc[2] ? mem_r.rdata[63:32] : mem_r.rdata[31:0];
          end
        end else if (flush) begin
          flush_rdata_next = 1;
          pc_next = dnpc;
        end
      end
      ST_HOLD: begin
        if (flush) begin
          state_next = ST_REQ;
          pc_next = dnpc;
        end else if (out_ready & out_valid) begin
          state_next = ST_REQ;
          pc_next = pc + pc_incr;
        end
      end
      default: ;
    endcase
  end

  assign out_valid = (state == ST_HOLD) & ~flush;
  assign out_pc = pc;
  assign out_inst = inst;

  assign mem_r.arvalid = ~reset & (state == ST_REQ);
  assign mem_r.araddr = pc;
  assign mem_r.arid = 4'b0;
  assign mem_r.arlen = 8'b0; // no burst
  assign mem_r.arsize = 3'b010; // 4B
  assign mem_r.arburst = 2'b0;
  assign mem_r.rready = (state == ST_RESP);
`else
  reg [31:0] pc, inst;

  wire [31:0] imm_b = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};

  always @(posedge clock) begin
    if (reset) begin
      pc <= 32'h80000000;
      inst <= pmem_read(32'h80000000);
    end else begin
      if (flush) begin
        pc <= dnpc;
        inst <= pmem_read(dnpc);
      end else if (out_ready) begin
        if ((inst[6:2] == 5'b11000) & inst[31]) begin // 分支，并且后向
          pc <= pc + imm_b;
          inst <= pmem_read(pc + imm_b);
        end else begin
          pc <= pc + 4;
          inst <= pmem_read(pc + 4);
        end
      end
    end
  end
  assign out_valid = ~reset & ~flush;
  assign out_pc = pc;
  assign out_inst = inst;
`endif
endmodule
