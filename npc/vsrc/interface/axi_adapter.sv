module axi_adapter (
  axi_if.slave master,
  axi_if.master slave
);

  // slave->master
  assign master.awready = slave.awready;
  assign master.wready  = slave.wready;
  assign master.bvalid  = slave.bvalid;
  assign master.bresp   = slave.bresp;
  assign master.bid     = slave.bid;
  assign master.arready = slave.arready;
  assign master.rvalid  = slave.rvalid;
  assign master.rresp   = slave.rresp;
  assign master.rdata   = slave.rdata;
  assign master.rlast   = slave.rlast;
  assign master.rid     = slave.rid;
  // master->slave
  assign slave.awvalid = master.awvalid;
  assign slave.awaddr  = master.awaddr;
  assign slave.awid    = master.awid;
  assign slave.awlen   = master.awlen;
  assign slave.awsize  = master.awsize;
  assign slave.awburst = master.awburst;
  assign slave.wvalid  = master.wvalid;
  assign slave.wdata   = master.wdata;
  assign slave.wstrb   = master.wstrb;
  assign slave.wlast   = master.wlast;
  assign slave.bready  = master.bready;
  assign slave.arvalid = master.arvalid;
  assign slave.araddr  = master.araddr;
  assign slave.arid    = master.arid;
  assign slave.arlen   = master.arlen;
  assign slave.arsize  = master.arsize;
  assign slave.arburst = master.arburst;
  assign slave.rready  = master.rready;

endmodule
