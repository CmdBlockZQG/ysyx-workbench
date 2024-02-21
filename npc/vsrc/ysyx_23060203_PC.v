module ysyx_23060203_PC (
  input rstn, clk,

  input dnpcen, // 是否需要外部提供下一个PC
  input [31:0] dnpc, // 动态的下一个PC

  output reg [31:0] pc
);
  always @(posedge clk) begin
    if (rstn) begin
      pc <= dnpcen ? dnpc : pc + 4;
    end else begin
      pc <= 32'h80000000; // 复位0x80000000
    end
  end
endmodule
