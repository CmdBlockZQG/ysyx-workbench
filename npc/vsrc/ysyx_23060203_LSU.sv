module ysyx_23060203_LSU (
  input rstn, clk,

  // 访存读请求
  input [31:0] raddr,
  input [2:0] rfunc,
  decouple_if.in rreq,
  // 访存读回复
  output reg [31:0] rdata,
  decouple_if.out rres,
  // 访存写
  input [2:0] wfunc,
  input [31:0] waddr,
  input [31:0] wdata,
  decouple_if.in wreq,
  decouple_if.out wres,

  // 连接存储器
  axi_lite_r_if.master ram_r,
  // axi_lite_w_if.master ram_w,
  axi_if.master ram_w
);
  // -------------------- 读请求 --------------------
  // 暂存寄存器
  reg [1:0] raddr_align_reg;
  reg [2:0] rfunc_reg;

  // 组合逻辑
  reg [31:0] ram_r_rdata_shifted;
  always_comb begin
    case (raddr_align_reg)
      2'b00: ram_r_rdata_shifted = ram_r.rdata;
      2'b01: ram_r_rdata_shifted = {8'b0, ram_r.rdata[31:8]};
      2'b10: ram_r_rdata_shifted = {16'b0, ram_r.rdata[31:16]};
      2'b11: ram_r_rdata_shifted = {24'b0, ram_r.rdata[31:24]};
      default: ram_r_rdata_shifted = ram_r.rdata;
    endcase
  end
  reg [31:0] ram_r_rdata_word;
  always_comb begin
    case (rfunc_reg)
      LD_BS: ram_r_rdata_word = {{24{ram_r_rdata_shifted[7]}}, ram_r_rdata_shifted[7:0]};
      LD_BU: ram_r_rdata_word = {24'b0, ram_r_rdata_shifted[7:0]};
      LD_HS: ram_r_rdata_word = {{16{ram_r_rdata_shifted[15]}}, ram_r_rdata_shifted[15:0]};
      LD_HU: ram_r_rdata_word = {16'b0, ram_r_rdata_shifted[15:0]};
      // LD_W : ram_r_rdata_word = ram_r_rdata_shifted;
      default: ram_r_rdata_word = ram_r_rdata_shifted; // 与LD_W合并
    endcase
  end

  // 信号转发
  assign ram_r.arvalid = rreq.valid;
  assign ram_r.araddr = raddr;
  assign rreq.ready = ram_r.arready;
  always @(posedge clk) begin
    if (rreq.valid & rreq.ready) begin
      raddr_align_reg <= raddr[1:0];
      rfunc_reg <= rfunc;
    end
  end
  // TEMP: 忽略回复错误处理
  assign rdata = ram_r_rdata_word;
  assign rres.valid = ram_r.rvalid;
  assign ram_r.rready = rres.ready;

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

  reg [31:0] wdata_aligned;
  always_comb begin
    case (waddr[1:0])
      2'b00: wdata_aligned = wdata;
      2'b01: wdata_aligned = {wdata[23:0], 8'b0};
      2'b10: wdata_aligned = {wdata[15:0], 16'b0};
      2'b11: wdata_aligned = {wdata[7:0], 24'b0};
      default: wdata_aligned = wdata;
    endcase
  end
  reg [3:0] wmask; //未对齐的wmask,基准是没有去掉末尾的waddr
  always_comb begin
    case (wfunc)
      ST_B: wmask = 4'b0001;
      ST_H: wmask = 4'b0011;
      // ST_W: wmask = 4'b1111;
      default: wmask = 4'b1111; // 合并ST_W
    endcase
  end
  reg [3:0] wmask_aligned;
  always_comb begin
    case (waddr[1:0])
      2'b00: wmask_aligned = wmask;
      2'b01: wmask_aligned = {wmask[2:0], 1'b0};
      2'b10: wmask_aligned = {wmask[1:0], 2'b0};
      2'b11: wmask_aligned = {wmask[0:0], 3'b0};
      default: wmask_aligned = wmask;
    endcase
  end

  reg waddr_flag, wdata_flag;
  always @(posedge clk) begin
    if (~rstn) begin
      waddr_flag <= 1;
      wdata_flag <= 1;
    end
    if (ram_w.awvalid & ram_w.awready) begin
      waddr_flag <= 0;
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
  assign ram_w.wdata = {32'b0, wdata_aligned};
  assign ram_w.wstrb = {4'b0, wmask_aligned};
  assign ram_w.wvalid = wreq.valid & wdata_flag;
  assign wreq.ready = (ram_w.awready | ~waddr_flag) & (ram_w.wready | ~wdata_flag);
  // TEMP: 忽略回复错误处理
  assign wres.valid = ram_w.bvalid;
  assign ram_w.bready = wres.ready;

endmodule
