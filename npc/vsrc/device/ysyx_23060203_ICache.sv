module ysyx_23060203_ICache_new (
  input rstn, clk,

  axi_if.slave ifu_in,
  axi_if.master ram_out
);
  parameter OFFSET_W = 4; // 块内地址宽度，块大小=2^x字节
  parameter INDEX_W  = 2; // 组地址宽度，组数=2^x
  parameter TAG_W    = 32 - OFFSET_W - INDEX_W; // 标记字宽度

  parameter SET_N = 1 << INDEX_W; // 组数
  parameter BLOCK_W = (1 << OFFSET_W) << 3; // 块位宽
  parameter BLOCK_SZ = (1 << OFFSET_W) >> 2; // 一块中几个32位的部分

  // TEMP: 直接映射实现
  reg line_valid [SET_N];
  reg [TAG_W-1:0] line_tag [SET_N];
  reg [31:0] line_data [SET_N][BLOCK_SZ];

  wire [TAG_W-1:0] req_tag = ifu_in.araddr[31:OFFSET_W+INDEX_W];
  wire [INDEX_W-1:0] req_index = ifu_in.araddr[OFFSET_W+INDEX_W-1:OFFSET_W];
  wire [(OFFSET_W-2)-1:0] req_off = ifu_in.araddr[OFFSET_W-1:2];

  reg [TAG_W-1:0] tag_reg;
  reg [INDEX_W-1:0] index_reg;
  reg [(OFFSET_W-2)-1:0] off_reg;

  wire [TAG_W-1:0] tag = ifu_in.arvalid ? req_tag : tag_reg;
  wire [INDEX_W-1:0] index = ifu_in.arvalid ? req_index : index_reg;
  wire [(OFFSET_W-2)-1:0] off = ifu_in.arvalid ? req_off : off_reg;
  wire [(OFFSET_W-2)-1:0] off_next = off + 1;
  wire [31:0] addr = {tag, index, off, 2'b0};

  wire enable = addr[31:28] >= 4'h3; // 覆盖flash和sdram，排除很快的sram TEMP: 还没启用
  wire cache_hit = line_valid[index] & (line_tag[index] == tag);
  wire [31:0] cache_out = line_data[index][off];
  reg cache_out_valid;

  // read burst
  assign ram_out.arsize = 3'b010; // 4 Bytes
  assign ram_out.arlen = BLOCK_SZ - 1; // burst length = BLOCK_SZ
  assign ram_out.arburst = (BLOCK_SZ == 1) ? 2'b00 : 2'b10; // wrap burst

  assign ram_out.arvalid = ~cache_hit & ifu_in.arvalid;
  assign ram_out.araddr = {tag, index, off_next, 2'b00};

  assign ram_out.rready = 1;
  assign ifu_in.rvalid = cache_out_valid | (ram_out.rvalid & ram_out.rlast);
  assign ifu_in.rdata = cache_out_valid ? {2{cache_out}} : ram_out.rdata;

  integer i;
  always @(posedge clk) if (~rstn) begin
    for (i = 0; i < SET_N; i = i + 1) line_valid[i] <= 0;
    ifu_in.arready <= 1;
    cache_out_valid <= 0;
  end else begin
    if (ifu_in.arvalid & ifu_in.arready) begin
      tag_reg <= req_tag;
      index_reg <= req_index;
      off_reg <= req_off;
      if (cache_hit) cache_out_valid <= 1;
      else ifu_in.arready <= 0;
    end
    if (ram_out.rvalid & ram_out.rready) begin
      if (ram_out.rlast) begin
        ifu_in.arready <= 1;
        line_valid[index] <= 1;
        line_tag[index] <= tag;
      end
      line_data[index][off_next] <= ~off[0] ? ram_out.rdata[63:32] : ram_out.rdata[31:0];
      off_reg <= off_reg + 1;
    end
    if (ifu_in.rvalid & ifu_in.rready) begin
      if (cache_out_valid) begin
        cache_out_valid <= 0;
`ifndef SYNTHESIS
        perf_event(PERF_ICACHE_HIT);
`endif
      end else begin
`ifndef SYNTHESIS
        perf_event(PERF_ICACHE_MISS);
`endif
      end
    end
  end

endmodule

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

  wire cache_hit_req = line_valid[index] & (line_tag[index] == tag);
  reg cache_hit_reg;
  wire cache_hit = ifu_in_ar_hs ? cache_hit_req : cache_hit_reg;
  wire [BLOCK_W-1:0] cache_out = line_data[index];

  reg cache_resp_valid;

  assign ram_out.arsize = 3'b010; // 4 Bytes
  assign ram_out.arlen = 8'b0;

  assign ram_out.arvalid = ~cache_hit & ifu_in.arvalid;
  assign ram_out.araddr = addr;

  assign ram_out.rready = ifu_in.rready;
  assign ifu_in.rvalid = cache_hit ? cache_resp_valid : ram_out.rvalid;
  assign ifu_in.rdata = cache_hit ? {2{cache_out}} : ram_out.rdata; // TEMP: 块大小32

  integer i;
  always @(posedge clk) if (~rstn) begin
    for (i = 0; i < SET_N; i = i + 1) line_valid[i] <= 0;
    ifu_in.arready <= 1;
    cache_resp_valid <= 0;
    cache_hit_reg <= 0;
  end else begin
    if (ifu_in_ar_hs) begin
      addr_reg <= ifu_in.araddr;
      cache_hit_reg <= cache_hit_req;
      if (cache_hit_req) cache_resp_valid <= 1;
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
