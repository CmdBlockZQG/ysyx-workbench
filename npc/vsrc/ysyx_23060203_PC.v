module ysyx_23060203_PC (
  input rstn, clk,

  input dnpc_en, // 是否需要外部提供下一个PC
  input [31:0] dnpc, // 动态的下一个PC

  output [31:0] next_pc,
  output reg [31:0] pc
);
  // 这里写dnpc_en & rstn是为了防止复位时dnpc_en为1
  // 如果设计保证复位时dnpc_en为0,则可以把这个条件改为只有dnpc_en
  assign next_pc = (dnpc_en & rstn) ? dnpc : pc + 4;
  // TODO: 控制跳转

  always @(posedge clk) begin
    if (rstn) begin
      pc <= next_pc;
    end else begin
      pc <= 32'h80000000 - 4; // 复位0x80000000
    end
  end
endmodule
