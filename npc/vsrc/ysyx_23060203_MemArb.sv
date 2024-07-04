module ysyx_23060203_MemArb (
  input rstn, clk,

  axi_if.slave ifu_r,
  axi_if.slave lsu_r,

  axi_if.master ram_r
);

  always @(posedge clk) begin
    if (~rstn) begin
      req_ready <= 1;
      lst_dev <= 0;
      tmp_flag <= 0;
    end
  end

  // TEMP: 不支持乱序读
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
  assign ram_r.arsize = tmp_flag ? tmp_rsize : (
    req_dev ? lsu_r.arsize : ifu_r.arsize
  );
  assign ram_r.arlen = tmp_flag ? tmp_rlen : (
    req_dev ? lsu_r.arlen : ifu_r.arlen
  );
  assign ram_r.arburst = tmp_flag ? tmp_rburst : (
    req_dev ? lsu_r.arburst : ifu_r.arburst
  );

  assign ifu_r.arready = req_ready & ram_r.arready;
  assign lsu_r.arready = req_ready & ram_r.arready;

  reg lst_dev;
  reg tmp_flag;
  reg [31:0] tmp_raddr;
  reg [2:0] tmp_rsize;
  reg [7:0] tmp_rlen;
  reg [1:0] tmp_rburst;
  always @(posedge clk) begin if (rstn) begin
    if (ram_r.arvalid & ram_r.arready) begin
      lst_dev <= req_dev;
      req_ready <= 0;
      if (ifu_r_hs & lsu_r_hs) begin // 同时读
        tmp_flag <= 1;
        tmp_raddr <= ifu_r.araddr;
        tmp_rsize <= ifu_r.arsize;
        tmp_rlen <= ifu_r.arlen;
        tmp_rburst <= ifu_r.arburst;
        req_ready <= 0;
      end else if (tmp_flag) begin // 暂存读
        tmp_flag <= 0;
      end
    end
  end end
  // res
  wire res_dev = lst_dev;

  assign ifu_r.rdata = ram_r.rdata;
  assign lsu_r.rdata = ram_r.rdata;
  assign ifu_r.rresp = ram_r.rresp;
  assign lsu_r.rresp = ram_r.rresp;
  assign ifu_r.rlast = ram_r.rlast;
  assign lsu_r.rlast = ram_r.rlast;
  assign ifu_r.rvalid = ~res_dev ? ram_r.rvalid : 0;
  assign lsu_r.rvalid = res_dev ? ram_r.rvalid : 0;
  assign ram_r.rready = res_dev ? lsu_r.rready : ifu_r.rready;

  always @(posedge clk) begin if (rstn) begin
    if (ram_r.rvalid & ram_r.rready & ram_r.rlast) begin
      req_ready <= ~tmp_flag;
    end
  end end
endmodule
