module npc_RAM (
  input rstn, clk,

  axi_if.slave in
);

  always @(posedge clk) if (~rstn) begin // 复位
    in.rvalid <= 0;

    in.awready <= 1;
    in.wready <= 1;
    in.bvalid <= 0;

    waddr_valid_reg <= 0;
    wdata_valid_reg <= 0;
  end

  assign in.arready = 1;
  assign in.rresp = 2'b00;
  always @(posedge clk) if (rstn) begin
    in.rvalid <= in.arvalid;
    if (in.arvalid) in.rdata <= {2{pmem_read(in.araddr)}};
    else in.rdata <= 64'b0;
//     if (in.rvalid & in.rready) in.rvalid <= 0;
//     if (in.arvalid & in.arready) begin
//       in.rvalid <= 1;
// `ifndef SYNTHESIS
      
// `else
      
// `endif
//     end
  end

  wire waddr_handshake = in.awready & in.awvalid;
  reg [31:0] waddr_reg;
  wire [31:0] waddr = waddr_handshake ? in.awaddr : waddr_reg;
  reg waddr_valid_reg;
  wire waddr_valid = waddr_handshake | waddr_valid_reg;

  wire wdata_handshake = in.wready & in.wvalid;
  reg [63:0] wdata_reg;
  reg [7:0] wmask_reg;
  wire [63:0] wdata = wdata_handshake ? in.wdata : wdata_reg;
  wire [7:0] wmask = wdata_handshake ? in.wstrb : wmask_reg;
  reg wdata_valid_reg;
  wire wdata_valid = wdata_handshake | wdata_valid_reg;

  wire write_en = waddr_valid & wdata_valid;

  always @(posedge clk) if (rstn) begin
    if (waddr_handshake) begin
      waddr_reg <= in.awaddr;
      if (~write_en) begin
        waddr_valid_reg <= 1;
        in.awready <= 0;
      end
    end
    if (wdata_handshake) begin
      wmask_reg <= in.wstrb;
      wdata_reg <= in.wdata;
      if (~write_en) begin
        wdata_valid_reg <= 1;
        in.wready <= 0;
      end
    end

    if (write_en) begin
`ifndef SYNTHESIS
      pmem_write({waddr[31:3], 3'b000}, wdata[31:0 ], {4'b0, wmask[3:0]});
      pmem_write({waddr[31:3], 3'b100}, wdata[63:32], {4'b0, wmask[7:4]});
`endif

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
