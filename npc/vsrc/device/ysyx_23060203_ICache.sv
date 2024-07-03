// module ysyx_23060203_ICache_new (
//   input rstn, clk,

//   axi_if.slave ifu_in,
//   axi_if.master ram_out
// );
//   parameter OFFSET_W = 4; // 块内地址宽度，块大小=2^x字节
//   parameter INDEX_W  = 2; // 组地址宽度，组数=2^x
//   parameter TAG_W    = 32 - OFFSET_W - INDEX_W; // 标记字宽度

//   parameter SET_N = 1 << INDEX_W; // 组数
//   parameter BLOCK_W = (1 << OFFSET_W) << 3; // 块位宽

//   // TEMP: 直接映射实现
//   reg line_valid [SET_N];
//   reg [TAG_W-1:0] line_tag [SET_N];
//   reg [BLOCK_W-1:0] line_data [SET_N];

//   wire ifu_in_ar_hs = ifu_in.arvalid & ifu_in.arready;
//   reg [31:0] addr_reg;
//   wire [31:0] addr = ifu_in_ar_hs ? ifu_in.araddr : addr_reg;
//   wire [31:0] aligned_addr = {addr[31:OFFSET_W], {OFFSET_W{1'b0}}};

//   wire enable = addr[31:28] >= 4'h3; // 覆盖flash和sdram，排除很快的sram
//   wire [INDEX_W-1:0] index = addr[OFFSET_W+INDEX_W-1:OFFSET_W];
//   wire [TAG_W-1:0] tag = addr[31:OFFSET_W+INDEX_W];

//   wire cache_hit = line_valid[index] & (line_tag[index] == tag);
//   wire [BLOCK_W-1:0] cache_out = line_data[index];

//   reg cache_resp_valid;

//   assign ram_out.arsize = 3'b010; // 4 Bytes

//   assign ram_out.arvalid = ~cache_hit & ifu_in.arvalid;
//   assign ram_out.araddr = addr;

//   assign ram_out.rready = 1;
//   assign ifu_in.rvalid = cache_hit ? cache_resp_valid : ram_out.rvalid;
//   assign ifu_in.rdata = cache_hit ? {2{cache_out}} : ram_out.rdata; // TEMP: 块大小32

//   integer i;
//   always @(posedge clk) if (~rstn) begin
//     for (i = 0; i < SET_N; i = i + 1) line_valid[i] <= 0;
//     ifu_in.arready <= 1;
//     cache_resp_valid <= 0;
//   end else begin
//     if (ifu_in_ar_hs) begin
//       addr_reg <= ifu_in.araddr;
//       if (cache_hit) cache_resp_valid <= 1;
//       else ifu_in.arready <= 0;
//     end

//     if (ifu_in.rvalid & ifu_in.rready) begin
//       if (cache_resp_valid) begin
//         cache_resp_valid <= 0;
// `ifndef SYNTHESIS
//         perf_event(PERF_ICACHE_HIT);
// `endif
//       end else begin
// `ifndef SYNTHESIS
//         perf_event(PERF_ICACHE_MISS);
// `endif
//       end
//     end

//     if (ram_out.rvalid & ram_out.rready) begin
//       ifu_in.arready <= 1;
//       if (enable) begin
//         line_valid[index] <= 1;
//         line_tag[index] <= tag;
//         line_data[index] <= addr[2] ? ram_out.rdata[63:32] : ram_out.rdata[31:0];
//       end
//     end
//   end

// endmodule

module ysyx_23060203_ICache (
  input rstn, clk,

  axi_if.slave ifu_in,
  axi_if.master ram_out
);
  parameter OFFSET_W = 2; // 块内地址宽度，块大小=2^x字节
  parameter INDEX_W  = 4; // 组地址宽度，组数=2^x
  parameter TAG_W    = 32 - OFFSET_W - INDEX_W; // 标记字宽度

  parameter SET_N = 1 << INDEX_W; // 组数
  parameter BLOCK_W = (1 << OFFSET_W) << 3; // 块位宽

  // TEMP: 直接映射实现
  reg line_valid [SET_N];
  reg [TAG_W-1:0] line_tag [SET_N];
  reg [BLOCK_W-1:0] line_data [SET_N];

  wire ifu_in_ar_hs = ifu_in.arvalid & ifu_in.arready;
  reg [31:0] addr_reg;
  wire [31:0] addr = ifu_in_ar_hs ? ifu_in.araddr : addr_reg;

  wire enable = addr[31:28] >= 4'h3; // 覆盖flash和sdram，排除很快的sram
  wire [INDEX_W-1:0] index = addr[OFFSET_W+INDEX_W-1:OFFSET_W];
  wire [TAG_W-1:0] tag = addr[31:OFFSET_W+INDEX_W];

  wire cache_hit = line_valid[index] & (line_tag[index] == tag);
  wire [BLOCK_W-1:0] cache_out = line_data[index];

  reg cache_resp_valid;

  assign ram_out.arsize = 3'b010; // 4 Bytes

  assign ram_out.arvalid = ~cache_hit & ifu_in.arvalid;
  assign ram_out.araddr = addr;

  assign ram_out.rready = 1;
  assign ifu_in.rvalid = cache_hit ? cache_resp_valid : ram_out.rvalid;
  assign ifu_in.rdata = cache_hit ? {2{cache_out}} : ram_out.rdata; // TEMP: 块大小32

  integer i;
  always @(posedge clk) if (~rstn) begin
    for (i = 0; i < SET_N; i = i + 1) line_valid[i] <= 0;
    ifu_in.arready <= 1;
    cache_resp_valid <= 0;
  end else begin
    if (ifu_in_ar_hs) begin
      addr_reg <= ifu_in.araddr;
      if (cache_hit) cache_resp_valid <= 1;
      else ifu_in.arready <= 0;
    end

    if (ifu_in.rvalid & ifu_in.rready) begin
      if (cache_resp_valid) begin
        cache_resp_valid <= 0;
`ifndef SYNTHESIS
        perf_event(PERF_ICACHE_HIT);
`endif
      end else begin
`ifndef SYNTHESIS
        perf_event(PERF_ICACHE_MISS);
`endif
      end
    end

    if (ram_out.rvalid & ram_out.rready) begin
      ifu_in.arready <= 1;
      if (enable) begin
        line_valid[index] <= 1;
        line_tag[index] <= tag;
        line_data[index] <= addr[2] ? ram_out.rdata[63:32] : ram_out.rdata[31:0];
      end
    end
  end

endmodule
