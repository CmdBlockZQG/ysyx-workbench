module CLINT (
  input rstn, clk,

  axi_lite_r_if.slave read
);
  // 计时
  reg [63:0] uptime;
  reg [15:0] acc;
  always @(posedge clk) begin
    if (rstn) begin
      if (acc == 2) begin
        acc <= 0;
        uptime <= uptime + 1;
      end else begin
        acc <= acc + 1;
      end
    end else begin
      uptime <= 0;
      acc <= 0;
      read.arready <= 1;
      read.rvalid <= 0;
    end
  end

  // 返回结果组合逻辑
  reg [1:0] rresp;
  reg [31:0] rdata;
  always_comb begin
    case (read.araddr)
      32'ha0000048: begin
        rresp = 2'b00;
        rdata = uptime[31:0];
      end
      32'ha000004c: begin
        rresp = 2'b00;
        rdata = uptime[63:32];
      end
      default: begin
        rresp = 2'b00;
        rdata = 0;
      end
    endcase
  end

  // axi通信时序逻辑
  reg [31:0] raddr;
  always @(posedge clk) begin if (rstn) begin
    if (read.rvalid & read.rready) read.rvalid <= 0;
    if (read.arready & read.arvalid) begin
      if (~read.rvalid) begin
        read.arready <= 1;
        read.rvalid <= 1;
        read.rresp <= rresp;
        read.rdata <= rdata;
      end else begin
        read.arready <= 0;
        raddr <= read.araddr;
      end
    end
    if (~read.arready & ~read.rvalid) begin
      read.rvalid <= 1;
      read.arready <= 1;
      read.rresp <= rresp;
      read.rdata <= rdata;
    end
  end end
endmodule
