module ysyx_23060203_CLINT (
  input rstn, clk,

  axi_if.slave read
);
  // 计时
  reg [63:0] uptime;
  reg [15:0] acc;
  always @(posedge clk) begin
    if (rstn) begin
      if (acc == 0) begin
        acc <= 0;
        uptime <= uptime + 1;
      end else begin
        acc <= acc + 1;
      end
    end else begin
      uptime <= 0;
      acc <= 0;
    end
  end

  assign read.arready = 1;
  assign read.rvalid = 1;
  assign read.rresp = 0;
  assign read.rdata = uptime;
  assign read.rlast = 1;
  assign read.rid = 0;
endmodule
