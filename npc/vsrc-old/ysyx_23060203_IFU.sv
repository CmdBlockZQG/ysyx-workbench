module ysyx_23060203_IFU (
  input rstn, clk,

  // 接收EXU跳转控制信号
  input [31:0] npc,

  // 向IDU传递pc和inst
  output reg [31:0] pc,
  output [31:0] inst,
  decouple_if.out inst_out,

  // 连接指令内存
  axi_if.master ram_r
);
  assign ram_r.arsize = 3'b010;

  always @(posedge clk) begin
    if (~rstn) begin // 复位
`ifdef YSYXSOC
      pc <= 32'h30000000;
      ram_r.araddr <= 32'h30000000;
`else
      pc <= 32'h80000000;
      ram_r.araddr <= 32'h80000000;
`endif
    end
  end

  // TEMP: 暂时不考虑错误处理
  assign inst_out.valid = ram_r.rvalid;
  assign ram_r.rready = inst_out.ready;
  assign ram_r.arvalid = inst_out.ready & rstn;
  assign inst = ram_r.araddr[2] ? ram_r.rdata[63:32] : ram_r.rdata[31:0];

  always @(posedge clk) begin if (rstn) begin
    // 确认ram收到地址
    if (ram_r.arvalid & ram_r.arready) begin
      pc <= ram_r.araddr;
    end

    // 确认下游收到数据
    if (inst_out.valid & inst_out.ready) begin
      // 接收npc
      ram_r.araddr <= npc;
`ifndef SYNTHESIS
      if (inst == 32'h100073) begin
        halt();
      end
      inst_complete(pc, inst);
`endif
    end
  end end

  // -------------------- 性能计数器 --------------------
`ifndef SYNTHESIS
  typedef enum { perf_none, perf_wait_mem, perf_wait_exu } perf_state_t;
  perf_state_t perf_st;
  always @(posedge clk) if (~rstn) begin
    perf_st <= perf_none;
  end else begin
    case (perf_st)
      perf_wait_mem: begin
        perf_event(PERF_IFU_WAIT_MEM);
        if (inst_out.valid & inst_out.ready) begin
          perf_st <= perf_wait_exu;
        end
      end
      perf_wait_exu: begin
        perf_event(PERF_IFU_WAIT_EXU);
        if (ram_r.arvalid & ram_r.arready) begin
          perf_event(PERF_IFU_FETCH);
          perf_st <= perf_wait_mem;
        end
      end
      default: begin
        if (ram_r.arvalid & ram_r.arready) begin
          perf_event(PERF_IFU_FETCH);
          perf_st <= perf_wait_mem;
        end
      end
    endcase
  end
`endif

endmodule
