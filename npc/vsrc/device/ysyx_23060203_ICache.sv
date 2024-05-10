module ysyx_23060203_ICache (
  input rstn, clk,

  axi_if.slave ifu_in,
  axi_if.master ram_out
);

  parameter OFFSET_W = 2; // 块字节数=2^x
  parameter INDEX_W  = 4; // 块数=2^x
  parameter TAG_W    = 32 - OFFSET_W - INDEX_W;

  parameter ROW_N = 1 << INDEX_W; // 块数
  parameter BLOCK_W = (1 << OFFSET_W) << 3; // 块位宽

  wire [31:0] addr = ifu_in.araddr;
  wire enable = addr[31:28] >= 4'h3; // 覆盖flash和sdram
  wire [INDEX_W-1:0] index = addr[OFFSET_W+INDEX_W-1:OFFSET_W];
  wire [TAG_W-1:0] tag = addr[31:OFFSET_W+INDEX_W];

  reg row_valid [ROW_N];
  reg [TAG_W-1:0] row_tag [ROW_N];
  reg [BLOCK_W-1:0] row_data [ROW_N];

  wire cache_valid = ifu_in.arvalid & row_valid[index] & (row_tag[index] == tag);
  wire [BLOCK_W-1:0] cache_out = row_data[index];

  assign ram_out.arsize = 3'b010;

  assign ifu_in.arready = ram_out.arready;
  assign ram_out.arvalid = ifu_in.arvalid;
  assign ram_out.araddr = ifu_in.araddr;

  assign ram_out.rready = ifu_in.rready;
  assign ifu_in.rvalid = ram_out.rvalid;
  assign ifu_in.rdata = ram_out.rdata;

  always @(posedge clk) if (~rstn) begin
    
  end else begin
    
  end

endmodule
