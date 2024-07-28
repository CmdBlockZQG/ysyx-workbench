module ysyx_23060203_LSU (
  input rstn, clk,

  // 访存读请求
  input [31:0] raddr,
  input [2:0] rfunc,
  decouple_if.in rreq,
  // 访存读回复
  output [31:0] rdata,
  decouple_if.out rres,
  // 访存写
  input [2:0] wfunc,
  input [31:0] waddr,
  input [31:0] wdata,
  decouple_if.in wreq,
  decouple_if.out wres,

  // 连接存储器
  axi_if.master ram_r,
  axi_if.master ram_w
);

  `include "params/mem.sv"

  // -------------------- 读请求 --------------------
  assign ram_r.arlen = 0;
  assign ram_r.arburst = 2'b0;

  // 暂存寄存器
  reg [2:0] raddr_align_reg;
  reg [2:0] rfunc_reg;

  // 组合逻辑
  wire [63:0] ram_r_rdata_shifted = ram_r.rdata >> {raddr_align_reg, 3'b0};

  reg [31:0] ram_r_rdata_word;
  always_comb begin
    case (rfunc_reg)
      LD_BS: ram_r_rdata_word = {{24{ram_r_rdata_shifted[7]}}, ram_r_rdata_shifted[7:0]};
      LD_BU: ram_r_rdata_word = {24'b0, ram_r_rdata_shifted[7:0]};
      LD_HS: ram_r_rdata_word = {{16{ram_r_rdata_shifted[15]}}, ram_r_rdata_shifted[15:0]};
      LD_HU: ram_r_rdata_word = {16'b0, ram_r_rdata_shifted[15:0]};
      // LD_W : ram_r_rdata_word = ram_r_rdata_shifted;
      default: ram_r_rdata_word = ram_r_rdata_shifted[31:0]; // 与LD_W合并
    endcase
  end

  // 信号转发
  assign ram_r.arvalid = rreq.valid;
  assign ram_r.araddr = raddr;
  always_comb begin
    case (rfunc)
      LD_BS, LD_BU: ram_r.arsize = 3'b000;
      LD_HS, LD_HU: ram_r.arsize = 3'b001;
      default: ram_r.arsize = 3'b010; // 合并LD_W
    endcase
  end

  assign rreq.ready = ram_r.arready;
  always @(posedge clk) begin
    if (rreq.valid & rreq.ready) begin
      raddr_align_reg <= raddr[2:0];
      rfunc_reg <= rfunc;
    end
  end
  // TEMP: 忽略回复错误处理
  assign rdata = ram_r_rdata_word;
  assign rres.valid = ram_r.rvalid;
  assign ram_r.rready = rres.ready;

`ifndef SYNTHESIS
  always @(posedge clk) begin
    if (rstn & ram_r.rvalid & ram_r.rready) begin
      event_mem_read(raddr, {29'b0, ram_r.arsize}, rdata);
    end
  end
`endif

  // -------------------- 写请求 --------------------
  assign ram_w.awid = 0;
  assign ram_w.awlen = 0;
  assign ram_w.awburst = 0;
  assign ram_w.wlast = 1;
  always_comb begin
    case (wfunc)
      // ST_B: ram_w.awsize = 3'b000;
      ST_H: ram_w.awsize = 3'b001;
      ST_W: ram_w.awsize = 3'b010;
      default: ram_w.awsize = 3'b000; // 合并ST_B
    endcase
  end

  wire [63:0] wdata_aligned = {32'b0, wdata} << {waddr[2:0], 3'b0};
  reg [7:0] wmask; //未对齐的wmask,基准是没有去掉末尾的waddr
  always_comb begin
    case (wfunc)
      ST_B: wmask = 8'b00000001;
      ST_H: wmask = 8'b00000011;
      // ST_W: wmask = 8'b00001111;
      default: wmask = 8'b00001111; // 合并ST_W
    endcase
  end
  wire [7:0] wmask_aligned = wmask << waddr[2:0];

  reg waddr_flag, wdata_flag;
  always @(posedge clk) begin
    if (~rstn) begin
      waddr_flag <= 1;
      wdata_flag <= 1;
    end

    if (ram_w.awvalid & ram_w.awready) begin
      waddr_flag <= 0;
`ifndef SYNTHESIS
      event_mem_write(waddr, {29'b0, ram_w.awsize}, wdata);
`endif
    end
    if (ram_w.wvalid & ram_w.wready) begin
      wdata_flag <= 0;
    end
    if (ram_w.bvalid & ram_w.bready) begin
      waddr_flag <= 1;
      wdata_flag <= 1;
    end
  end
  assign ram_w.awaddr = waddr;
  assign ram_w.awvalid = wreq.valid & waddr_flag;
  assign ram_w.wdata = wdata_aligned;
  assign ram_w.wstrb = wmask_aligned;
  assign ram_w.wvalid = wreq.valid & wdata_flag;
  assign wreq.ready = (ram_w.awready | ~waddr_flag) & (ram_w.wready | ~wdata_flag);
  // TEMP: 忽略回复错误处理
  assign wres.valid = ram_w.bvalid;
  assign ram_w.bready = wres.ready;

  // -------------------- 性能计数器 --------------------
`ifndef SYNTHESIS
  reg perf_reading, perf_writing;
  always @(posedge clk) if (~rstn) begin
    perf_reading <= 0;
    perf_writing <= 0;
  end else begin
    if (perf_reading) perf_event(PERF_LSU_LOAD);
    if (ram_r.arvalid & ram_r.arready) perf_reading <= 1;
    if (ram_r.rvalid & ram_r.rready) begin
      perf_reading <= 0;
      perf_event(PERF_LSU_LOAD_RESP);
    end

    if (perf_writing) perf_event(PERF_LSU_STORE);
    if (ram_w.awvalid & ram_w.awready) perf_writing <= 1; // TEMP: 目前，地址和数据会同时提供
    if (ram_w.bvalid & ram_w.bready) perf_writing <= 0;
  end
`endif

endmodule
