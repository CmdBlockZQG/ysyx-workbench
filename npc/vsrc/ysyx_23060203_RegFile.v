module ysyx_23060203_RegFile (
  input clk,

  input wen, // 写入使能
  input [31:0] wdata, // 写入数据
  input [4:0] waddr, // 写入地址

  input [4:0] raddr, // 读出地址
  output [31:0] rdata // 读出数据
);
  reg [31:0] rf [1:31];

  // 读逻辑
  assign rdata = raddr == 5'b0 ? 0 : rf[raddr];

  // 写逻辑
  always @(posedge clk) begin
    if (wen && waddr != 5'b0) begin // $0不可写
      rf[waddr] <= wdata;
    end
  end
endmodule
