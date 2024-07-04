module ysyx_23060203_Xbar (
  input rstn, clk,

  axi_if.slave read,
  axi_if.master soc_r,
  axi_if.master clint_r
);
  // 复位
  always @(posedge clk) begin if (~rstn) begin
    rreq_ready <= 1;
    rres_soc <= 0;
    rres_clint <= 0;
  end end

  // -------------------- Read --------------------

  // TEMP: 不支持乱序读
  assign clint_r.arid = 0;
  assign soc_r.arid = 0;

  // req
  reg rreq_ready;
  wire rreq_soc = ~rreq_clint;
  assign soc_r.araddr = read.araddr;
  assign soc_r.arsize = read.arsize;
  assign soc_r.arlen = read.arlen;
  assign soc_r.arburst = read.arburst;
  assign clint_r.araddr = read.araddr;
  assign clint_r.arsize = read.arsize;
  assign clint_r.arlen = read.arlen;
  assign clint_r.arburst = read.arburst;

`ifdef YSYXSOC
  wire rreq_clint = (read.araddr[31:16] == 16'h0200);
`else
  wire rreq_clint = (read.araddr[31:4] == 28'ha000004);
`endif

  always_comb begin
    if (rreq_soc) begin
      read.arready = rreq_ready & soc_r.arready;
      soc_r.arvalid = rreq_ready & read.arvalid;
      clint_r.arvalid = 0;
    end else if (rreq_clint) begin
      read.arready = rreq_ready & clint_r.arready;
      clint_r.arvalid = rreq_ready & read.arvalid;
      soc_r.arvalid = 0;
    end else begin
      read.arready = 0;
      soc_r.arvalid = 0;
      clint_r.arvalid = 0;
    end
  end
  always @(posedge clk) begin if (rstn) begin
    if (read.arvalid & read.arready) begin
      rres_soc <= rreq_soc;
      rres_clint <= rreq_clint;
      rreq_ready <= 0;
    end
  end end
  // res
  reg rres_soc, rres_clint;
  assign soc_r.rready = rres_soc & read.rready;
  assign clint_r.rready = rres_clint & read.rready;
  always_comb begin
    if (rres_soc) begin
      read.rdata = soc_r.rdata;
      read.rresp = soc_r.rresp;
      read.rvalid = soc_r.rvalid;
      read.rlast = soc_r.rlast;
    end else if (rres_clint) begin
      read.rdata = clint_r.rdata;
      read.rresp = clint_r.rresp;
      read.rvalid = clint_r.rvalid;
      read.rlast = clint_r.rlast;
    end else begin
      read.rdata = 0;
      read.rresp = 0;
      read.rvalid = 0;
      read.rlast = 0;
    end
  end
  always @(posedge clk) begin if (rstn) begin
    if (read.rvalid & read.rready & read.rlast) begin
      rreq_ready <= 1;
    end
  end end
endmodule
