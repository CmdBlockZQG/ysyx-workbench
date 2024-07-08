module ysyx_23060203_IFU (
  input clock, reset,

  input out_ready,
  output out_valid,
  output [31:0] pc_out,
  output [31:0] inst_out,

  axi_if.out ram_r
);

  // TODO: 状态机IFU,需要流水化

  typedef enum {
    ST_REQ,  // 发出请求，等待ar通道握手
    ST_RESP, // 等待数据，等待r通道握手
    ST_HOLD  // 保持指令数据，等待下游接收
  } state_t;

  state_t state, state_next;
  reg [31:0] pc, pc_next;
  reg [31:0] inst, inst_next;

  always @(posedge clock) begin
    if (reset) begin
      state <= ST_REQ;
      inst <= 32'h00000013; // nop
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
    end
  end

  always_comb begin
    state_next = state;
    pc_next = pc;
    inst_next = inst;
    case (state)
      ST_REQ: begin
        if (ram_r.arready & ram_r.arvalid) begin
          state_next = ST_RESP;
        end
      end
      ST_RESP: begin
        if (ram_r.rready & ram_r.rvalid) begin
          state_next = ST_HOLD;
          inst_next = ram_r.raddr;
        end
      end
      ST_HOLD: begin
        if (out_ready & out_valid) begin
          state_next = ST_REQ;
          pc_next = pc + 32'h4;
        end
      end
      default: ;
    endcase
  end

  assign out_valid = (state == ST_HOLD);
  assign pc_out = pc;
  assign inst_out = inst;

  assign ram_r.arvalid = ~reset & (state == ST_REQ);
  assign ram_r.araddr = pc;
  assign ram_r.arid = 4'b0;
  assign ram_r.arlen = 3'b010; // 4B
  assign ram_r.arsize = 3'b0; // no burst
  assign ram_r.arburst = 2'b0;
  assign ram_r.rready = (state == ST_RESP);
endmodule
