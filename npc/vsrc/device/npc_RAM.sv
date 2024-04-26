module npc_RAM (
  input rstn, clk,

  axi_if.slave in
);
  reg reading, writing;
  always @(posedge clk) if (~rstn) begin // 复位
    in.arready <= 1;
    in.rvalid <= 0;
    reading <= 0;

    in.awready <= 1;
    in.wready <= 1;
    in.bvalid <= 0;
    writing <= 0;

    waddr_valid_reg <= 0;
    wdata_valid_reg <= 0;
  end

  reg [31:0] raddr;
  always @(posedge clk) if (rstn) begin
    if (in.rvalid & in.rready) in.rvalid <= 0;
    if (in.arready & in.arvalid) begin
      in.arready <= 0;
      raddr <= in.araddr;
      reading <= 1;
    end

    if (~in.arready & reading & ~in.rvalid) begin
      reading <= 0;
      in.rvalid <= 1;
      in.rdata <= {2{mem_read(raddr)}};
      in.rresp <= 2'b00;
      in.arready <= 1;
    end
  end

  wire waddr_handshake = in.awready & in.awvalid;
  reg [31:0] waddr_reg;
  wire [31:0] waddr = waddr_handshake ? in.awaddr : waddr_reg;
  reg waddr_valid_reg;
  wire waddr_valid = waddr_handshake | waddr_valid_reg;

  wire wdata_handshake = in.wready & in.wvalid;
  reg [63:0] wdata_reg;
  reg [7:0] wmask_reg;
  wire [61:0] wdata = wdata_handshake ? in.wdata : wdata_reg;
  wire [7:0] wmask = wdata_handshake ? in.wstrb : wmask_reg;
  reg wdata_valid_reg;
  wire wdata_valid = wdata_handshake | wdata_valid_reg;

  wire write_en = waddr_valid & wdata_valid;

  always @(posedge clk) if (rstn) begin
    if (waddr_handshake) begin
      waddr_reg <= in.awaddr;
      in.awready <= 0;
      if (~write_en) waddr_valid_reg <= 1;
    end
    if (wdata_handshake) begin
      wmask_reg <= in.wstrb;
      wdata_reg <= in.wdata;
      in.wready <= 0;
      if (~write_en) wdata_valid_reg <= 1;
    end

    if (write_en) begin
      mem_write({waddr[31:3], 3'b000}, wdata[31:0 ], wmask_reg[3:0]);
      mem_write({waddr[31:3], 3'b100}, wdata[63:32], wmask_reg[7:4]);

      in.bresp <= 2'b00;
      in.bvalid <= 1;
      in.awready <= 1;
      in.wready <= 1;

      waddr_valid_reg <= 0;
      wdata_valid_reg <= 0;
    end

    if (in.bvalid & in.bready) in.bvalid <= 0;
  end
endmodule
