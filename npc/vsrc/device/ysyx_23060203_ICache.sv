module ysyx_23060203_ICache (
  input rstn, clk,

  axi_if.slave ifu_in,
  axi_if.master ram_out
);

  parameter OFFSET_W = 2; // 块字节数=2^
  parameter INDEX_W  = 4; // 块数=2^
  parameter TAG_W    = 32 - OFFSET_W - INDEX_W;

  assign ram_out.arsize = 3'b010;

  assign ifu_in.arready = ram_out.arready;
  assign ram_out.arvalid = ifu_in.arvalid;
  assign ram_out.araddr = ifu_in.araddr;

  assign ram_out.rready = ifu_in.rready;
  assign ifu_in.rvalid = ram_out.rvalid;
  assign ifu_in.rdata = ram_out.rdata;

endmodule
