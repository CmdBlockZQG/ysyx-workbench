module ysyx_23060203_CSR (
  input rstn, clk,

  input [11:0] raddr, // 读取地址
  output reg [31:0] rdata, // 读出数据

  input wen1, // 写入使能
  input [11:0] waddr1, // 写入地址
  input [31:0] wdata1, // 写入数据
  input wen2, // 写入使能
  input [11:0] waddr2, // 写入地址
  input [31:0] wdata2 // 写入数据
);

  `include "params/csr.sv"

  reg [31:0] mstatus, mtvec, mepc, mcause;

  // 读逻辑
  always_comb begin
    case (raddr)
      CSR_MSTATUS : rdata = mstatus;
      CSR_MTVEC   : rdata = mtvec;
      CSR_MEPC    : rdata = mepc;
      CSR_MCAUSE  : rdata = mcause;

      CSR_MVENDORID : rdata = 32'h79737978;
      CSR_MARCHID   : rdata = 32'h015fdeeb;

      default     : rdata = 32'b0;
    endcase
  end

  // 写逻辑
  always @(posedge clk) begin
    if (rstn) begin
      if (wen1) begin
        case (waddr1)
          CSR_MSTATUS : mstatus <= wdata1;
          CSR_MTVEC   : mtvec   <= wdata1;
          CSR_MEPC    : mepc    <= wdata1;
          CSR_MCAUSE  : mcause  <= wdata1;
          default: ;
        endcase
      end
      if (wen2) begin
        case (waddr2)
          CSR_MSTATUS : mstatus <= wdata2;
          CSR_MTVEC   : mtvec   <= wdata2;
          CSR_MEPC    : mepc    <= wdata2;
          CSR_MCAUSE  : mcause  <= wdata2;
          default: ;
        endcase
      end
    end else begin // 复位
      mstatus <= 32'h1800;
      mtvec   <= 32'b0;
      mepc    <= 32'b0;
      mcause  <= 32'b0;
    end
  end
endmodule
