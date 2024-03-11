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
  wire [31:0] npc_base = ovrd ? ovrd_addr : pc;
  wire [31:0] npc_orig = npc_base + inc;
  wire [31:0] next_pc = {npc_orig[31:1], 1'b0};

  reg rstn_prev;
  reg [31:0] inst_reg, npc_reg;
  reg [31:0] pc_reg [3];
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
      ram_r.araddr <= pc;
      pc_reg[0] <= pc;
    end

    // 读入npc
    if (npc_in.ready & npc_in.valid) begin
      if (~ram_r.arvalid) begin // 尝试向ram传递地址
        ram_r.arvalid <= 1;
        npc_in.ready <= 1;
        ram_r.araddr <= next_pc;
        pc_reg[0] <= next_pc;
      end else begin // ram暂时无法接收地址，暂存
        npc_in.ready <= 0;
        npc_reg <= next_pc;
      end
    end

    // 向ram传递暂存的地址
    if (~ram_r.arvalid & ~npc_in.ready) begin
      ram_r.arvalid <= 1;
      npc_in.ready <= 1;
      ram_r.araddr <= npc_reg;
      pc_reg[0] <= npc_reg;
    end

    // 确认ram收到地址
    if (ram_r.arvalid & ram_r.arready) begin
      ram_r.arvalid <= 0;
      pc_reg[1] <= pc_reg[0];
    end

    // 从ram接收指令 TEMP: 暂时不考虑错误处理，不管resp
    if (ram_r.rready & ram_r.rvalid) begin
      if (~inst_out.valid) begin
        ram_r.rready <= 1;
        inst_out.valid <= 1;
        inst <= ram_r.rdata;
        pc <= pc_reg[1];
      end else begin
        ram_r.rready <= 0;
        inst_reg <= ram_r.rdata;
        pc_reg[2] <= pc_reg[1];
      end
    end

    // 向下面的模块传递指令 TEMP: 暂时不考虑错误处理，不管resp
    if (~ram_r.rready & ~inst_out.valid) begin
      ram_r.rready <= 1;
      inst_out.valid <= 1;
      inst <= inst_reg;
      pc <= pc_reg[2];
    end

    // 确认下游收到数据
    if (inst_out.valid & inst_out.ready) begin
      inst_out.valid <= 0;
    end
  end
endmodule
