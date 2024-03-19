module ysyx_23060203_Xbar (
  input rstn, clk,

  axi_lite_r_if.slave read,
  axi_lite_r_if.master sram_r,
  axi_lite_r_if.master clint_r,

  axi_lite_w_if.slave write,
  axi_lite_w_if.master sram_w,
  axi_lite_w_if.master uart_w
);
  // 复位
  always @(posedge clk) begin if (~rstn) begin
    rreq_ready <= 1;
    rres_sram <= 0;
    rres_clint <= 0;

    wreq_ready <= 1;
    wres_sram <= 0;
    wres_uart <= 0;
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
      if (~rreq_sram) begin
        skip_difftest();
      end
    end
  end end
  // res
  reg rres_sram, rres_clint;
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
  // req
  reg wreq_ready;
  wire wreq_sram = (write.awaddr[31:27] == 5'b10000);
  assign sram_w.awaddr = write.awaddr;
  wire wreq_uart = (write.awaddr == 32'ha00003f8);
  assign uart_w.awaddr = write.awaddr;
  always_comb begin
    if (wreq_sram) begin
      write.awready = wreq_ready & sram_w.awready;
      sram_w.awvalid = wreq_ready & write.awvalid;
      uart_w.awvalid = 0;
    end else if (wreq_uart) begin
      write.awready = wreq_ready & uart_w.awready;
      uart_w.awvalid = wreq_ready & write.awvalid;
      sram_w.awvalid = 0;
    end else begin
      write.awready = 0;
      sram_w.awvalid = 0;
      uart_w.awvalid = 0;
    end
  end
  always @(posedge clk) begin if (rstn) begin
    if (write.awvalid & write.awready) begin
      wres_sram <= wreq_sram;
      wres_uart <= wreq_uart;
      wreq_ready <= 0;

      if (~wreq_sram) begin
        skip_difftest();
      end
    end
  end end
  // res
  reg wres_sram, wres_uart;
  assign sram_w.wvalid = wres_sram & write.wvalid;
  assign sram_w.bready = wres_sram & write.bready;
  assign uart_w.wvalid = wres_uart & write.wvalid;
  assign uart_w.bready = wres_uart & write.bready;
  always_comb begin
    if (wres_sram) begin
      sram_w.wdata = write.wdata;
      sram_w.wstrb = write.wstrb;
      uart_w.wdata = 0;
      uart_w.wstrb = 0;

      write.wready = sram_w.wready;
      write.bresp = sram_w.bresp;
      write.bvalid = sram_w.bvalid;
    end else if (wres_uart) begin
      uart_w.wdata = write.wdata;
      uart_w.wstrb = write.wstrb;
      sram_w.wdata = 0;
      sram_w.wstrb = 0;

      write.wready = uart_w.wready;
      write.bresp = uart_w.bresp;
      write.bvalid = uart_w.bvalid;
    end else begin
      uart_w.wdata = 0;
      uart_w.wstrb = 0;
      sram_w.wdata = 0;
      sram_w.wstrb = 0;

      write.wready = 0;
      write.bresp = 0;
      write.bvalid = 0;
    end
  end
  always @(posedge clk) begin
    if (write.bvalid & write.bready) begin
      wreq_ready <= 1;
      wres_sram <= 0;
      wres_uart <= 0;
    end
  end
endmodule
