interface axi_lite_r_if;
  // 读地址
  logic [31:0] araddr;
  logic arvalid;
  logic arready;
  // 读数据
  logic [31:0] rdata;
  logic [1:0] rresp;
  logic rvalid;
  logic rready;

  modport master (
    output araddr, arvalid,
    input arready,

    input rdata, rresp, rvalid,
    output rready
  );

  modport slave (
    input araddr, arvalid,
    output arready,

    output rdata, rresp, rvalid,
    input rready
  );
endinterface

interface axi_lite_w_if;
  // 写地址
  logic [31:0] awaddr;
  logic awvalid;
  logic awready;
  // 写数据
  logic [31:0] wdata;
  logic [3:0] wstrb;
  logic wvalid;
  logic wready;
  // 写回复
  logic [1:0] bresp;
  logic bvalid;
  logic bready;

  modport master (
    output awaddr, awvalid,
    input awready,

    output wdata, wstrb, wvalid,
    input wready,

    input bresp, bvalid,
    output bready
  );

  modport slave (
    input awaddr, awvalid,
    output awready,

    input wdata, wstrb, wvalid,
    output wready,

    output bresp, bvalid,
    input bready
  );
endinterface
