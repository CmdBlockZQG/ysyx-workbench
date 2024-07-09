module ysyx_23060203_GPR #(NR_REG = 16) (
  input clock, reset,

  input wen, // 写入使能
  input [4:0] waddr, // 写入地址
  input [31:0] wdata, // 写入数据

  input [4:0] raddr1, // 读出地址
  output [31:0] rdata1, // 读出数据
  input [4:0] raddr2, // 读出地址
  output [31:0] rdata2 // 读出数据
);
  // -------------------- WRITE --------------------
  reg [31:0] r [1:NR_REG-1]/*verilator public*/;
  reg [31:0] r_next [1:NR_REG-1];

  integer i;
  always @(posedge clock) begin
    for (i = 1; i < NR_REG; i = i + 1) begin
      r[i] <= reset ? 32'h0 : r_next;
    end
  end

  always_comb begin
    for (i = 1; i < NR_REG; i = i + 1) begin
      r_next[i] = (i == waddr) ? wdata : r[i];
    end
  end

  // -------------------- READ --------------------
  assign rdata1 = raddr1 == 5'b0 ? 0 : r[raddr1];
  assign rdata2 = raddr2 == 5'b0 ? 0 : r[raddr2];
endmodule
