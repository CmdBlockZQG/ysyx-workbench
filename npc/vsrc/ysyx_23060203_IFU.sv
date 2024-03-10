`include "interface/axi.sv"
`include "interface/decouple.sv"

module ysyx_23060203_IFU (
  input rstn, clk,

  // 接收EXU跳转控制信号
  input [31:0] inc, // pc增量，默认情况下应该是4
  input ovrd, // 新地址不再由原来的pc加上增量得到
  input [31:0] ovrd_addr, // ovrd为1时有效，用于替换pc
  decouple_if.in npc_in,

  output reg [31:0] pc,
  output reg [31:0] inst,
  decouple_if.out inst_out,

  axi_r_if.master ram_r
);

  // FIXME: 这个pc传递还是错的
  wire [31:0] npc_base = ovrd ? ovrd_addr : pc;
  wire [31:0] npc_orig = npc_base + inc;
  wire [31:0] next_pc = {npc_orig[31:1], 1'b0};

  reg rstn_prev;
  reg [31:0] inst_reg, npc_reg;
  always @(posedge clk) begin
    rstn_prev <= rstn;
    if (~rstn) begin // 复位
      npc_in.ready <= 0;
      inst_out.valid <= 0;
      ram_r.arvalid <= 0;
      ram_r.rready <= 0;
      pc <= 32'h80000000;
    end else if (rstn & ~rstn_prev) begin // 复位释放
      npc_in.ready <= 1;
      inst_out.valid <= 0;
      ram_r.arvalid <= 1;
      ram_r.rready <= 1;
      ram_r.araddr <= 32'h80000000;
    end

    // 向ram传递地址
    if (~ram_r.arvalid & ~npc_in.ready) begin
      ram_r.arvalid <= 1;
      npc_in.ready <= 1;
      ram_r.araddr <= npc_reg;
    end

    // 确认ram收到地址
    if (ram_r.arvalid & ram_r.arready) begin
      ram_r.arvalid <= 0;
    end

    // 从ram接收指令
    if (ram_r.rready & ram_r.rvalid) begin
      ram_r.rready <= 0;
      // TEMP: 暂时不考虑错误处理，不管resp
      // resp_reg <= ram_r.rresp
      inst_reg <= ram_r.rdata;
    end

    // 向下面的模块传递指令
    if (~ram_r.rready & ~inst_out.valid) begin
      ram_r.rready <= 1;
      inst_out.valid <= 1;
      inst <= inst_reg;
      // TEMP: 暂时不考虑错误处理，不管resp
    end

    // 确认下游收到数据
    if (inst_out.valid & inst_out.ready) begin
      inst_out.valid <= 0;
    end

    // 读入npc
    if (npc_in.ready & npc_in.valid) begin
      npc_in.ready <= 0;
      npc_reg <= next_pc;
    end
  end
endmodule
