module ysyx_23060203_MemArb (
  input rstn, clk,

  axi_lite_r_if.slave ifu_r,
  axi_lite_r_if.slave lsu_r,

  // axi_lite_r_if.master ram_r
  axi_if.master ram_r
);

  always @(posedge clk) begin
    if (~rstn) begin
      req_ready <= 1;
      lst_dev <= 0;
      tmp_flag <= 0;
    end
  end

  assign ram_r.arsize = 3'b010;
  assign ram_r.arlen = 0;
  assign ram_r.arburst = 0;
  assign ram_r.arid = 0;

  // req
  reg req_ready;

  wire ifu_r_hs = ifu_r.arvalid & ifu_r.arready;
  wire lsu_r_hs = lsu_r.arvalid & lsu_r.arready;

  wire req_dev = tmp_flag ? 0 : ( // 暂存的请求一定是ifu
    (ifu_r.arvalid & lsu_r.arvalid) ? 1 : lsu_r.arvalid // 同时优先lsu
  );

  assign ram_r.arvalid = tmp_flag ? 1 : (
    req_ready & (req_dev ? lsu_r.arvalid : ifu_r.arvalid)
  );
  assign ram_r.araddr = tmp_flag ? tmp_raddr : (
    req_dev ? lsu_r.araddr : ifu_r.araddr
  );

  assign ifu_r.arready = req_ready & ram_r.arready;
  assign lsu_r.arready = req_ready & ram_r.arready;

  reg lst_dev, res_hl;
  reg tmp_flag;
  reg [31:0] tmp_raddr;
  always @(posedge clk) begin if (rstn) begin
    if (ram_r.arvalid & ram_r.arready) begin
      lst_dev <= req_dev;
      res_hl <= ram_r.araddr[2];
      req_ready <= 0;
      if (ifu_r_hs & lsu_r_hs) begin // 同时读
        tmp_flag <= 1;
        tmp_raddr <= ifu_r.araddr;
        req_ready <= 0;
      end else if (tmp_flag) begin // 暂存读
        tmp_flag <= 0;
      end
    end
  end end
  // res
  wire res_dev = lst_dev;

  wire [31:0] ram_r_rdata_hl = res_hl ? ram_r.rdata[63:32] : ram_r.rdata[31:0];
  assign ifu_r.rdata = ram_r_rdata_hl;
  assign lsu_r.rdata = ram_r_rdata_hl;
  assign ifu_r.rresp = ram_r.rresp;
  assign lsu_r.rresp = ram_r.rresp;
  assign ifu_r.rvalid = ~res_dev ? ram_r.rvalid : 0;
  assign lsu_r.rvalid = res_dev ? ram_r.rvalid : 0;
  assign ram_r.rready = res_dev ? lsu_r.rready : ifu_r.rready;

  always @(posedge clk) begin if (rstn) begin
    if (ram_r.rvalid & ram_r.rready) begin
      req_ready <= ~tmp_flag;
    end
  end end
endmodule
