module SRAM (
  input rstn, clk,
  // 读地址
  input [31:0] araddr,
  input arvalid,
  output reg arready,
  // 读数据
  output reg [31:0] rdata,
  output reg [1:0] rresp,
  output reg rvalid,
  input rready,
  // 写地址
  input [31:0] awaddr,
  input awvalid,
  output reg awready,
  // 写数据
  input [31:0] wdata,
  input [3:0] wstrb,
  input wvalid,
  output reg wready,
  // 写回复
  output reg [1:0] bresp,
  output reg bvalid,
  input bready
);
  `include "DPIC.v"

  reg rstn_prev;
  always @(posedge clk) begin
    rstn_prev <= rstn;
    if (rstn) begin // 复位
      arready <= 0;
      rvalid <= 0;
      reading <= 0;

      awready <= 0;
      wready <= 0;
      writing <= 0;
      bvalid <= 0;
    end else if (~rstn & rstn_prev) begin // 复位释放
      arready <= 1;
      rvalid <= 0;
      reading <= 0;

      awready <= 1;
      wready <= 1;
      writing <= 0;
      bvalid <= 0;
    end
  end

  reg [31:0] raddr_reg;
  reg reading;
  always @(posedge clk) begin
    if (arready) begin
      // 等待arvalid
      if (arvalid) begin // 握手成功
        arready <= 0;
        raddr_reg <= araddr;
        reading <= 1;
      end
    end else begin
      if (reading & ~rvalid) begin
        reading <= 0;
        rvalid <= 1;
        rdata <= mem_read(raddr_reg);
        arready <= 1;
      end
    end

    if (rvalid & rready) rvalid <= 0;
  end

  reg [31:0] waddr_reg, wdata_reg;
  reg [3:0] wmask_reg;
  reg writing;
  wire waddr_handshake = awready & awvalid;
  wire wdata_handshake = wready & wvalid;
  always @(posedge clk) begin
    if (waddr_handshake) begin
      waddr_reg <= awaddr;
      awready <= 0;
      if (~wready | wdata_handshake) writing <= 1;
    end
    if (wdata_handshake) begin
      wmask_reg <= wstrb;
      wdata_reg <= wdata;
      wready <= 0;
      if (~awready | waddr_handshake) writing <= 1;
    end

    if (writing & ~bvalid) begin
      mem_write(waddr_reg, wdata_reg, {4'b0, wmask_reg});
      writing <= 0;
      bresp <= 2'b00;
      bvalid <= 1;
    end

    if (bvalid & bready) bvalid <= 0;
  end
endmodule
