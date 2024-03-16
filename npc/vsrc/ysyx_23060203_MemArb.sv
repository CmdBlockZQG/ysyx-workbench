`include "interface/axi.sv"

module ysyx_23060203_MemArb (
  input rstn, clk,

  axi_r_if.slave ifu_r,
  axi_r_if.slave lsu_r,

  axi_r_if.master ram_r
);

  reg req_ready;
  // 约定：dev0表示ifu，dev1表示lsu
  reg lst_dev;
  wire res_dev = lst_dev;
  // FIXME: 如果发生死锁，这里的轮替策略可能要改成LSU优先
  wire req_dev = (ifu_r.arvalid & lsu_r.arvalid) ? ~lst_dev : lsu_r.arvalid;

  assign ram_r.araddr = req_dev ? lsu_r.araddr : ifu_r.araddr;
  always_comb begin
    if (req_ready) begin
      ram_r.arvalid = req_dev ? lsu_r.arvalid : ifu_r.arvalid;
      ifu_r.arready = ~req_dev ? ram_r.arready : 0;
      lsu_r.arready = req_dev ? ram_r.arready : 0;
    end else begin
      ram_r.arvalid = 0;
      ifu_r.arready = 0;
      lsu_r.arready = 0;
    end
  end

  assign ifu_r.rdata = ram_r.rdata;
  assign lsu_r.rdata = ram_r.rdata;
  assign ifu_r.rresp = ram_r.rresp;
  assign lsu_r.rresp = ram_r.rresp;
  assign ifu_r.rvalid = ~res_dev ? ram_r.rvalid : 0;
  assign lsu_r.rvalid = res_dev ? ram_r.rvalid : 0;
  assign ram_r.rready = res_dev ? lsu_r.rready : ifu_r.rready;

  always @(posedge clk) begin
    if (~rstn) begin
      req_ready <= 1;
      lst_dev <= 0;
    end
  end

  always @(posedge clk) begin if (rstn) begin
    if (ram_r.arvalid & ram_r.arready) begin
      lst_dev <= req_dev;
      // res_dev <= req_dev;
    end

    if (ram_r.rvalid & ram_r.rready) begin
      req_ready <= 1;
    end else if (ram_r.arvalid & ram_r.arready) begin
      req_ready <= 0;
    end
  end end
endmodule
