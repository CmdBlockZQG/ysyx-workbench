`include "interface/axi.sv"

module ysyx_23060203_MemArb (
  input rstn, clk,

  axi_r_if.slave ifu_r,
  axi_r_if.slave lsu_r,

  axi_r_if.master ram_r
);
  reg rstn_prev;
  always @(posedge clk) begin
    rstn_prev <= rstn;
    if (~rstn) begin
      ifu_r.arready <= 0;
      ifu_r.rvalid <= 0;
      lsu_r.arready <= 0;
      lsu_r.rvalid <= 0;
      ram_r.arvalid <= 0;
      ram_r.rready <= 0;
    end else if (rstn & ~rstn_prev) begin
      ifu_r.arready <= 1;
      ifu_r.rvalid <= 0;
      lsu_r.arready <= 1;
      ifu_r.rvalid <= 0;
      ram_r.arvalid <= 0;
      ram_r.rready <= 0;
    end
  end

  reg [31:0] ifu_raddr, lsu_raddr;
  reg dev [4];
  reg [31:0] rdata;
  reg [1:0] rresp;
  always @(posedge clk) begin
    // 从master读取地址
    if (ifu_r.arready & ifu_r.arvalid) begin
      ifu_r.arready <= 0;
      ifu_raddr <= ifu_r.araddr;
    end
    if (lsu_r.arready & lsu_r.arvalid) begin
      lsu_r.arready <= 0;
      lsu_raddr <= lsu_r.araddr;
    end

    // 向slave传递地址
    if (~ifu_r.arready & ~lsu_r.arready) begin
      // 同时读请求
      if (dev[0]) begin // 轮到ifu
        dev[0] <= 0;
        ram_r.arvalid <= 1;
        ram_r.araddr <= ifu_raddr;
        dev[1] <= 0;
        ifu_r.arready <= 1;
      end else begin // 轮到lsu
        dev[0] <= 1;
        ram_r.arvalid <= 1;
        ram_r.araddr <= lsu_raddr;
        dev[1] <= 1;
        lsu_r.arready <= 1;
      end
    end

    // 确认slave收到地址
    if (ram_r.arvalid & ram_r.arready) begin
      ram_r.arvalid <= 0;
      ram_r.rready <= 1;
      dev[2] <= dev[1];
    end

    // 从slave接收数据
    if (ram_r.rready & ram_r.rvalid) begin
      ram_r.rready <= 0;
      rdata <= ram_r.rdata;
      rresp <= ram_r.rresp;
      dev[3] <= dev[2];
    end

    // 向master传递数据
    if (~ram_r.rready) begin
      if (dev[3] & ~lsu_r.rvalid) begin
        ram_r.rready <= 1;
        lsu_r.rvalid <= 1;
        lsu_r.rdata <= rdata;
        lsu_r.rresp <= rresp;
      end else if (~dev[3] & ~ifu_r.rvalid) begin
        ram_r.rready <= 1;
        ifu_r.rvalid <= 1;
        ifu_r.rdata <= rdata;
        ifu_r.rresp <= rresp;
      end
    end

    // 确认master收到数据
    if (ifu_r.rvalid & ifu_r.rready) begin
      ifu_r.rvalid <= 0;
    end
    if (lsu_r.rvalid & lsu_r.rready) begin
      lsu_r.rvalid <= 0;
    end
  end
endmodule
