module ysyx_23060203_IFU (
  input rstn, clk,

  input [31:0] next_pc,
  output reg [31:0] inst
);
  `include "dpic.v"
  always @(posedge clk) begin
    if (rstn) begin
      inst <= mem_read(next_pc);
    end else begin
      inst <= 32'hffffffff;
      // 这个指令还需要保证使得EXU一定会将pc_inc设为4，pc_ovrd设为0
      // 改动PC和跳转部分设计时务必检查
    end
  end
endmodule
