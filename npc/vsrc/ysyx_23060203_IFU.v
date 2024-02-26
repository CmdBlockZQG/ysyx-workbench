module ysyx_23060203_IFU (
  input rstn, clk,

  input [31:0] next_pc,
  output reg [31:0] inst,

  output [31:0] inst_mem_addr,
  input [31:0] inst_mem_data // TODO: 去掉这个，改成DPI-C
);
  // 这里暂时把指令内存当作组合逻辑,根据next_pc加载下一条指令
  assign inst_mem_addr = next_pc;

  always @(posedge clk) begin
    if (rstn) begin
      inst <= inst_mem_data;
    end else begin
      inst <= 32'b0; // 全0是非法指令
    end
  end
endmodule
