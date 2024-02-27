module ysyx_23060203_PC (
  input rstn, clk,

  // 连接EXU输出，控制跳转
  input [31:0] inc, // pc增量，默认情况下应该是4
  input ovrd, // 新地址不再依赖原来的pc（用于JALR）
  input [31:0] ovrd_addr, // ovrd为1时有效，用于替换pc（用于JALR）

  output [31:0] next_pc,
  output reg [31:0] pc
);
  wire [31:0] npc_base = ovrd ? ovrd_addr : pc;
  wire [31:0] npc_orig = npc_base + inc;
  // JALR指令要求目标地址最后一位清零
  // 如果只支持对齐内存访问的话（特别是指令内存），可以统一去掉最后一位
  assign next_pc = {npc_orig[31:1], npc_orig[0] & (~ovrd)};

  always @(posedge clk) begin
    if (rstn) begin
      pc <= next_pc;
    end else begin
      pc <= 32'h80000000 - 4; // 复位0x80000000
      // 这样做需要保证在复位和复位释放后第一个时钟上升沿到来之前ovrd为0且inc为4
      // 改动PC和跳转部分设计时务必检查复位后pc值的正确性
    end
  end
endmodule
