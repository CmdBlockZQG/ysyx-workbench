`include "interface/axi.sv"

module ysyx_23060203_MemArb (
  input rstn, clk,

  axi_r_if.slave ifu_r,
  axi_r_if.slave lsu_r,

  axi_r_if.master ram_r
);
  always @(posedge clk) begin
    if (~rstn) begin
      ifu_r.arready <= 1;
      ifu_r.rvalid <= 0;
      lsu_r.arready <= 1;
      lsu_r.rvalid <= 0;
      ram_r.arvalid <= 0;
      ram_r.rready <= 1;
    end
  end

  reg [31:0] ifu_raddr, lsu_raddr;
  reg dev [3];
  reg [31:0] rdata;
  reg [1:0] rresp;
  always @(posedge clk) begin if (rstn) begin
    // 从master读取地址
    if (ifu_r.arready & ifu_r.arvalid) begin
      if (lsu_r.arready) begin // 没有暂存的读地址，可以直接向slave传递地址
        dev[0] <= 0;
        ram_r.arvalid <= 1;
        ram_r.araddr <= ifu_r.araddr;
        ifu_r.arready <= 1;
      end else begin // 暂存地址
        ifu_r.arready <= 0;
        ifu_raddr <= ifu_r.araddr;
      end
    end
    if (lsu_r.arready & lsu_r.arvalid) begin
      if (ifu_r.arready) begin
        dev[0] <= 1;
        ram_r.arvalid <= 1;
        ram_r.araddr <= lsu_raddr;
        lsu_r.arready <= 1;
      end else begin
        lsu_r.arready <= 0;
        lsu_raddr <= lsu_r.araddr;
      end
    end

    // 向slave传递暂存的地址
    if (~ram_r.arvalid) begin
      if (~ifu_r.arready & (lsu_r.arready | dev[0])) begin
        dev[0] <= 0;
        ram_r.arvalid <= 1;
        ram_r.araddr <= ifu_raddr;
        ifu_r.arready <= 1;
      end else if (~lsu_r.arready & (ifu_r.arready | ~dev[0])) begin
        dev[0] <= 1;
        ram_r.arvalid <= 1;
        ram_r.araddr <= lsu_raddr;
        lsu_r.arready <= 1;
      end
    end

    // 确认slave收到地址
    if (ram_r.arvalid & ram_r.arready) begin
      ram_r.arvalid <= 0;
      dev[1] <= dev[0];
    end

    // 从slave接收数据
    if (ram_r.rready & ram_r.rvalid) begin
      if (dev[1] & ~lsu_r.rvalid) begin
        ram_r.rready <= 1;
        lsu_r.rvalid <= 1;
        lsu_r.rdata <= ram_r.rdata;
        lsu_r.rresp <= ram_r.rresp;
      end else if (~dev[1] & ~ifu_r.rvalid) begin
        ram_r.rready <= 1;
        ifu_r.rvalid <= 1;
        ifu_r.rdata <= ram_r.rdata;
        ifu_r.rresp <= ram_r.rresp;
      end else begin // 暂存
        ram_r.rready <= 0;
        rdata <= ram_r.rdata;
        rresp <= ram_r.rresp;
        dev[2] <= dev[1];
      end
    end

    // 向master传递暂存的数据
    if (~ram_r.rready) begin
      if (dev[2] & ~lsu_r.rvalid) begin
        ram_r.rready <= 1;
        lsu_r.rvalid <= 1;
        lsu_r.rdata <= rdata;
        lsu_r.rresp <= rresp;
      end else if (~dev[2] & ~ifu_r.rvalid) begin
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
  end end
endmodule
