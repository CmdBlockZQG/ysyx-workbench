module ysyx_23060203_MEM (
  input rstn, clk,

  input wen, // 写入使能
  input [2:0] wfunc, // 写入funct（位宽）
  input [31:0] wdata, // 写入数据
  input [31:0] waddr, // 写入地址

  input ren, // 读请求有效
  input [2:0] rfunc, // 读出funct（位宽）
  input [31:0] raddr, // 读出地址
  output reg [31:0] rdata // 读出数据
);
  `include "dpic.v"
  `include "params/mem.v"

  // 内存读当作组合逻辑
  // 访存时，读地址的最后两位会被忽略
  // 读取单字节或半字时需要重新处理对齐
  // 这里的实现不支持非对齐访存，需要至少对齐到读取的长度
  reg [31:0] rword_aligned;
  always @(ren, raddr) begin
    if (rstn & ren) begin
      rword_aligned = mem_read(raddr);
    end else begin
      rword_aligned = 32'b0;
    end
  end

  reg [31:0] rword;
  always_comb begin
    case (raddr[1:0])
      2'b00: rword = rword_aligned;
      2'b01: rword = {8'b0, rword_aligned[31:8]};
      2'b10: rword = {16'b0, rword_aligned[31:16]};
      2'b11: rword = {24'b0, rword_aligned[31:24]};
      default: rword = rword_aligned;
    endcase
  end

  always_comb begin
    case (rfunc)
      LD_BS: rdata = {{24{rword[7]}}, rword[7:0]};
      LD_BU: rdata = {24'b0, rword[7:0]};
      LD_HS: rdata = {{16{rword[15]}}, rword[15:0]};
      LD_HU: rdata = {16'b0, rword[15:0]};
      // LD_W : rdata = rword;
      default: rdata = rword; // 与LD_W合并
    endcase
  end

  // 内存写在时钟上升沿触发
  reg [7:0] wmask;
  always_comb begin
    case (wfunc)
      ST_B: wmask = 8'b00000001;
      ST_H: wmask = 8'b00000011;
      // ST_W: wmask = 8'b00001111;
      default: wmask = 8'b00001111; // 与ST_W合并
    endcase
  end

  always @(posedge clk) begin
    if (wen) begin
      mem_write(waddr, wdata, wmask);
    end
  end
endmodule
