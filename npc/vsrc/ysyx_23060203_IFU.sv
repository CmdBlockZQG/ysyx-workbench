`include "interface/axi.sv"
`include "interface/decouple.sv"

module ysyx_23060203_IFU (
  input rstn, clk,

  // 接收EXU跳转控制信号
  input [31:0] npc,

  // 向IDU传递pc和inst
  output reg [31:0] pc,
  output [31:0] inst,
  decouple_if.out inst_out,

  // 连接指令内存
  axi_r_if.master ram_r
);
  `include "DPIC.sv"

  reg rstn_prev;
  // reg [31:0] inst_reg;

  always @(posedge clk) begin
    rstn_prev <= rstn;
    if (~rstn) begin // 复位
      ram_r.arvalid <= 0;
      pc <= 32'h80000000;
    end else if (rstn & ~rstn_prev) begin // 复位释放
      ram_r.arvalid <= 1;
      ram_r.araddr <= pc;
    end
  end

  // TEMP: 暂时不考虑错误处理
  assign inst_out.valid = ram_r.rvalid;
  assign ram_r.rready = inst_out.ready;
  assign inst = ram_r.rdata;

  always @(posedge clk) begin if (rstn) begin
    // 确认ram收到地址
    if (ram_r.arvalid & ram_r.arready) begin
      ram_r.arvalid <= 0;
      pc <= ram_r.araddr;
    end

    // 确认下游收到数据
    if (inst_out.valid & inst_out.ready) begin
      // 接收npc
      ram_r.arvalid <= 1;
      ram_r.araddr <= npc;
      if (inst == 32'h100073) begin
        halt();
      end
      inst_complete(pc);
    end
  end end
endmodule
