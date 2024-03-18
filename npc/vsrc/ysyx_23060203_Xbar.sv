`include "interface/axi.sv"

module ysyx_23060203_Xbar (
  input rstn, clk,

  axi_r_if.slave read,
  axi_r_if.master sram_r,
  axi_r_if.master clint_r,

  axi_w_if.slave write,
  axi_w_if.master sram_w,
  axi_w_if.master uart_w
);
  // 复位
  always @(posedge clk) begin if (~rstn) begin
    rreq_ready <= 1;
  end end

  // -------------------- Read --------------------
  reg rreq_ready;
  reg [31:0] read_araddr_reg;
  wire [31:0] read_araddr = read.arvalid ? read.araddr : read_araddr_reg;
  always @(posedge clk) begin
    if (read.arvalid & read.arready) begin
      read_araddr_reg <= read.araddr;
      rreq_ready <= 0;
    end

    if (read.rvalid & read.rready) begin
      rreq_ready <= 1;
    end
  end

  wire rdev_sram = (read_araddr[31:27] == 5'b10000);
  assign sram_r.araddr = read.araddr;
  assign sram_r.arvalid = rreq_ready & rdev_sram & read.arvalid;
  assign sram_r.rready = rdev_sram & read.rready;

  wire rdev_clint = (read_araddr[31:3] == {28'ha000004, 1'b1}); // 0xa0000048
  assign clint_r.araddr = read.araddr;
  assign clint_r.arvalid = rreq_ready & rdev_clint & read.arvalid;
  assign clint_r.rready = rdev_clint & read.rready;

  always_comb begin
    if (rdev_sram) begin
      read.arready = rreq_ready ? sram_r.arready : 0;
      read.rdata = sram_r.rdata;
      read.rresp = sram_r.rresp;
      read.rvalid = sram_r.rvalid;
    end else if (rdev_clint) begin
      read.arready = rreq_ready ? clint_r.arready : 0;
      read.rdata = clint_r.rdata;
      read.rresp = clint_r.rresp;
      read.rvalid = clint_r.rvalid;
    end else begin
      read.arready = 0;
      read.rdata = 0;
      read.rresp = 0;
      read.rvalid = 0;
    end
  end
endmodule
