`include "interface/axi.sv"

module SRAM (
  input rstn, clk,

  axi_r_if.slave read,
  axi_w_if.slave write
);
  `include "DPIC.sv"

  reg [7:0] reading, writing;
  reg [7:0] reading_max, writing_max;
  always @(posedge clk) begin
    if (~rstn) begin // 复位
      read.arready <= 1;
      read.rvalid <= 0;
      reading <= 0;

      write.awready <= 1;
      write.wready <= 1;
      write.bvalid <= 0;
      writing <= 0;
    end
  end

  reg [31:0] raddr;
  always @(posedge clk) begin if (rstn) begin
    if (read.rvalid & read.rready) read.rvalid <= 0;
    if (read.arready & read.arvalid) begin
      read.arready <= 0;
      raddr <= read.araddr;
      reading <= 1;
      reading_max <= lfsr_out;
    end

    if (reading != 0) begin
      reading <= reading + 1;
    end

    if (~read.arready & reading == reading_max & ~read.rvalid) begin
      reading <= 0;
      read.rvalid <= 1;
      read.rdata <= mem_read(raddr);
      read.rresp <= 2'b00;
      read.arready <= 1;
    end
  end end

  reg [31:0] waddr, wdata;
  reg [3:0] wmask_reg;
  wire waddr_handshake = write.awready & write.awvalid;
  wire wdata_handshake = write.wready & write.wvalid;
  always @(posedge clk) begin if (rstn) begin
    if (waddr_handshake) begin
      waddr <= write.awaddr;
      write.awready <= 0;
      if (~write.wready | wdata_handshake) begin
        writing <= 1;
        writing_max <= lfsr_out;
      end
    end
    if (wdata_handshake) begin
      wmask_reg <= write.wstrb;
      wdata <= write.wdata;
      write.wready <= 0;
      if (~write.awready | waddr_handshake) begin
        writing <= 1;
        writing_max <= lfsr_out;
      end
    end

    if (writing != 0) begin
      writing <= writing + 1;
    end

    if (writing == writing_max & ~write.bvalid) begin
      mem_write(waddr, wdata, {4'b0, wmask_reg});
      writing <= 0;
      write.bresp <= 2'b00;
      write.bvalid <= 1;
      write.awready <= 1;
      write.wready <= 1;
    end

    if (write.bvalid & write.bready) write.bvalid <= 0;
  end end

  wire [7:0] lfsr_out;
  LFSR8 lfsr (
    .clk(clk),
    .rstn(rstn), .s(~rstn),
    .in(8'b10101010),
    .out(lfsr_out)
  );

endmodule
