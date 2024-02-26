module ysyx_23060203_MEM (
  input rstn, clk,

  input wen, // 写入使能
  input [2:0] wfunc, // 写入funct（位宽）
  input [31:0] wdata, // 写入数据
  input [31:0] waddr, // 写入地址

  input [2:0] rfunc, // 读出funct（位宽）
  input [31:0] raddr, // 读出地址
  output [31:0] rdata // 读出数据
);
  // TODO: DPI-C
endmodule
