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
    rres_sram <= 0;
    rres_clint <= 0;
  end end

  // -------------------- Read --------------------
  // req
  reg rreq_ready;
  wire rreq_sram = (read.araddr[31:27] == 5'b10000);
  assign sram_r.araddr = read.araddr;
  wire rreq_clint = (read.araddr[31:3] == {28'ha000004, 1'b1});
  assign clint_r.araddr = read.araddr;
  always_comb begin
    if (rreq_sram) begin
      read.arready = rreq_ready & sram_r.arready;
      sram_r.arvalid = rreq_ready & read.arvalid;
      clint_r.arvalid = 0;
    end else if (rreq_clint) begin
      read.arready = rreq_ready & clint_r.arready;
      clint_r.arvalid = rreq_ready & read.arvalid;
      sram_r.arvalid = 0;
    end else begin
      read.arready = 0;
      sram_r.arvalid = 0;
      clint_r.arvalid = 0;
    end
  end
  always @(posedge clk) begin if (rstn) begin
    if (read.arvalid & read.arready) begin
      rres_sram <= rreq_sram;
      rres_clint <= rreq_clint;
      rreq_ready <= 0;
    end
  end end
  // res
  reg rres_sram;
  reg rres_clint;
  assign sram_r.rready = rres_sram & read.rready;
  assign clint_r.rready = rres_clint & read.rready;
  always_comb begin
    if (rres_sram) begin
      read.rdata = sram_r.rdata;
      read.rresp = sram_r.rresp;
      read.rvalid = sram_r.rvalid;
    end else if (rres_clint) begin
      read.rdata = clint_r.rdata;
      read.rresp = clint_r.rresp;
      read.rvalid = clint_r.rvalid;
    end else begin
      read.rdata = 0;
      read.rresp = 0;
      read.rvalid = 0;
    end
  end
  always @(posedge clk) begin if (rstn) begin
    if (read.rvalid & read.rready) begin
      rreq_ready <= 1;
    end
  end end

  // -------------------- Write --------------------
  assign sram_w.awaddr = write.awaddr;
  assign sram_w.awvalid = write.awvalid;
  assign sram_w.wdata = write.wdata;
  assign sram_w.wstrb = write.wstrb;
  assign sram_w.wvalid = write.wvalid;
  assign sram_w.bready = write.bready;

  assign write.awready = sram_w.awready;
  assign write.wready = sram_w.wready;
  assign write.bresp = sram_w.bresp;
  assign write.bvalid = sram_w.bvalid;

endmodule
