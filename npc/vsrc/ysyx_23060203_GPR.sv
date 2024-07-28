module ysyx_23060203_GPR #(NR_REG = 16) (
  input rstn, clk,

  input wen, // 写入使能
  input [4:0] waddr, // 写入地址
  input [31:0] wdata, // 写入数据

  input [4:0] raddr1, // 读出地址
  output [31:0] rdata1, // 读出数据
  input [4:0] raddr2, // 读出地址
  output [31:0] rdata2 // 读出数据
);
  reg [31:0] rf [1:NR_REG-1]/*verilator public*/;

  // 读逻辑
  assign rdata1 = raddr1 == 5'b0 ? 0 : rf[raddr1];
  assign rdata2 = raddr2 == 5'b0 ? 0 : rf[raddr2];

  // 写逻辑
  integer i;
  always @(posedge clk) begin
    if (rstn) begin
      if (wen && waddr != 5'b0) begin // $0不可写
        rf[waddr] <= wdata;
      end
    end else begin
      // 复位
      for (i = 1; i < NR_REG; i = i + 1) begin
        rf[i] <= 0;
      end
    end
  end
endmodule
