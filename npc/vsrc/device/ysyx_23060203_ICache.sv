// module ysyx_23060203_ICache (
//   input rstn, clk,

//   axi_if.slave ifu_in,
//   axi_if.master ram_out
// );

//   parameter OFFSET_W = 2; // 块字节数=2^x
//   parameter INDEX_W  = 4; // 块数=2^x
//   parameter TAG_W    = 32 - OFFSET_W - INDEX_W;

//   parameter ROW_N = 1 << INDEX_W; // 块数
//   parameter BLOCK_W = (1 << OFFSET_W) << 3; // 块位宽

//   wire ifu_in_ar_hs = ifu_in.arvalid & ifu_in.arready;
//   reg [31:0] addr_reg;
//   wire [31:0] addr = ifu_in_ar_hs ? ifu_in.araddr : addr_reg;

//   wire enable = addr[31:28] >= 4'h3; // 覆盖flash和sdram
//   wire [INDEX_W-1:0] index = addr[OFFSET_W+INDEX_W-1:OFFSET_W];
//   wire [TAG_W-1:0] tag = addr[31:OFFSET_W+INDEX_W];

//   reg row_valid [ROW_N];
//   reg [TAG_W-1:0] row_tag [ROW_N];
//   reg [BLOCK_W-1:0] row_data [ROW_N];

//   wire cache_valid = row_valid[index] & (row_tag[index] == tag);
//   wire [BLOCK_W-1:0] cache_out = row_data[index];

//   reg cache_resp_valid;

//   assign ram_out.arsize = 3'b010;

//   assign ram_out.arvalid = ~cache_valid & ifu_in.arvalid;
//   assign ram_out.araddr = addr;

//   assign ram_out.rready = 1;
//   assign ifu_in.rvalid = cache_valid ? cache_resp_valid : ram_out.rvalid;
//   assign ifu_in.rdata = cache_valid ? {2{cache_out}} : ram_out.rdata; // TEMP: 块大小32


//   always @(posedge clk) if (~rstn) begin
//     for (integer i = 0; i < ROW_N; i = i + 1) row_valid[i] <= 0;
//     ifu_in.arready <= 1;
//     cache_resp_valid <= 0;
//   end else begin
//     if (ifu_in_ar_hs) begin
//       addr_reg <= ifu_in.araddr;
//       if (cache_valid) cache_resp_valid <= 1;
//       else ifu_in.arready <= 0;
//     end

//     if (ifu_in.rvalid & ifu_in.rready) begin
//       if (cache_resp_valid) cache_resp_valid <= 0;
//     end

//     if (ram_out.rvalid & ram_out.rready) begin
//       ifu_in.arready <= 1;
//       if (enable) begin
//         row_valid[index] <= 1;
//         row_tag[index] <= tag;
//         row_data[index] <= addr[2] ? ram_out.rdata[63:32] : ram_out.rdata[31:0];
//       end
//     end
//   end

// endmodule
