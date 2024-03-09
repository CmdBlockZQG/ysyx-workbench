`include "interface/axi.sv"

module proxy (
  input rstn, clk,

  axi_r_if.slave read,

  axi_r_if.master sram
);

  reg rstn_prev;
  always @(posedge clk) begin
    rstn_prev <= rstn;
    if (~rstn) begin
      read.arready <= 0;
      read.rvalid <= 0;

      sram.arvalid <= 0;
      sram.rready <= 0;
    end else if (rstn & ~rstn_prev) begin
      read.arready <= 1;
      read.rvalid <= 0;

      sram.arvalid <= 0;
      sram.rready <= 0;
    end
  end

  reg [31:0] raddr, rdata;
  reg [1:0] rresp;
  always @(posedge clk) begin
    // 从master读取地址
    if (read.arready & read.arvalid) begin
      read.arready <= 0;
      raddr <= read.araddr;
    end

    // 向slave传递地址
    if (~read.arready & ~sram.arvalid) begin
      sram.arvalid <= 1;
      sram.araddr <= raddr;
      read.arready <= 1;
    end

    // 确认slave收到地址
    if (sram.arvalid & sram.arready) begin
      sram.arvalid <= 0;
      sram.rready <= 1; // 地址传递成功后，准备接受数据
    end

    // 从slave接收数据
    if (sram.rready & sram.rvalid) begin
      sram.rready <= 0;
      rdata <= sram.rdata;
      rresp <= sram.rresp;
    end

    // 向master传递数据
    if (~sram.rready & ~read.rvalid) begin
      sram.rready <= 1;
      read.rvalid <= 1;
      read.rdata <= rdata;
      read.rresp <= rresp;
    end

    // 确认master收到数据
    if (read.rvalid & read.rready) begin
      read.rvalid <= 0;
    end
  end
endmodule
