`include "interface/decouple.sv"
`include "interface/axi.sv"

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
  axi_r_if.master ram_r,
  axi_w_if.master ram_w
);
  `include "params/mem.sv"

  // 暂存寄存器
  reg [31:0] raddr_reg, rdata_reg;
  reg [1:0] raddr_align_reg;
  reg [2:0] rfunc_reg;

  reg [31:0] waddr_reg, wdata_reg;
  reg [3:0] wstrb_reg;
  reg wreq_flag_aw, wreq_flag_w;

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

  always @(posedge clk) begin
    if (~rstn) begin
      wreq.ready <= 1;
      wres.valid <= 0;
      ram_w.awvalid <= 0;
      ram_w.wvalid <= 0;
      ram_w.bready <= 1;

      wreq_flag_aw <= 0;
      wreq_flag_w <= 0;
    end
  end

  // -------------------- 读请求 --------------------
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

  always @(posedge clk) begin if (rstn) begin
    // -------------------- 写请求 --------------------
    // 接收写请求
    if (wreq.valid & wreq.ready) begin
      if (~ram_w.awvalid) begin
        ram_w.awvalid <= 1;
        ram_w.awaddr <= waddr;
        wreq_flag_aw <= 0;
      end else begin
        wreq.ready <= 0;
        waddr_reg <= waddr;
        wreq_flag_aw <= 1;
      end
      if (~ram_w.wvalid) begin
        ram_w.wvalid <= 1;
        ram_w.wdata <= wdata_aligned;
        ram_w.wstrb <= wmask_aligned;
        wreq_flag_w <= 0;
      end else begin
        wreq.ready <= 0;
        wstrb_reg <= wmask_aligned;
        wdata_reg <= wdata_aligned;
        wreq_flag_w <= 1;
      end
    end

    // 向ram发送写请求
    if (~wreq.ready) begin
      if (wreq_flag_aw & ~ram_w.awvalid) begin
        ram_w.awvalid <= 1;
        ram_w.awaddr <= waddr_reg;
        wreq_flag_aw <= 0;
        if ((wreq_flag_w & ~ram_w.wvalid) | ~wreq_flag_w) begin
          wreq.ready <= 1;
        end
      end
      if (wreq_flag_w & ~ram_w.wvalid) begin
        ram_w.wvalid <= 1;
        ram_w.wdata <= wdata_reg;
        ram_w.wstrb <= wstrb_reg;
        wreq_flag_w <= 0;
        if ((wreq_flag_aw & ~ram_w.awvalid) | ~wreq_flag_aw) begin
          wreq.ready <= 1;
        end
      end
    end

    // 确认ram收到写请求
    if (ram_w.awvalid & ram_w.awready) begin
      ram_w.awvalid <= 0;
    end
    if (ram_w.wvalid & ram_w.wready) begin
      ram_w.wvalid <= 0;
    end

    // 接收ram回复 TEMP: 忽略回复错误处理
    if (ram_w.bready & ram_w.bvalid) begin
      ram_w.bready <= 1;
      wres.valid <= 1;
    end

    // 确认返回被收到
    if (wres.valid & wres.ready) begin
      wres.valid <= 0;
    end
  end end
endmodule
