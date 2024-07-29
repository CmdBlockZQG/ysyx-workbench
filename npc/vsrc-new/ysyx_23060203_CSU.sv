module ysyx_23060203_CSU (
  input clock, reset,

  // CSR
  input [11:0] raddr, // 读取地址
  output reg [31:0] rdata, // 读出数据

  input wen, // 写入使能
  input [11:0] waddr, // 写入地址
  input [31:0] wdata, // 写入数据

  // status
  input jmp_corr,
  input [31:0] jmp_dnpc,

  input sys, exc, fencei,

  // control
  output ifu_flush, idu_flush, exu_flush,
  output [31:0] ifu_dnpc
);

  `include "def/csr.sv"

  // -------------------- WRITE --------------------
  reg [31:0] mstatus, mstatus_next;
  reg [31:0] mtvec, mtvec_next;
  reg [31:0] mepc, mepc_next;

  always @(posedge clock) begin
    if (reset) begin
      mstatus <= 32'h1800;
    end else begin
      mstatus <= mstatus_next;
      mtvec <= mtvec_next;
      mepc <= mepc_next;
    end
  end

  always_comb begin
    mstatus_next = mstatus;
    mtvec_next = mtvec;
    mepc_next = mepc;
    if (wen) begin
      case (waddr)
        CSR_MSTATUS : mstatus_next = wdata;
        CSR_MTVEC   : mtvec_next   = wdata;
        CSR_MEPC    : mepc_next    = wdata;
        default: ;
      endcase
    end
  end

  // -------------------- READ --------------------
  always_comb begin
    case (raddr)
      CSR_MSTATUS : rdata = mstatus;
      CSR_MTVEC   : rdata = mtvec;
      CSR_MEPC    : rdata = mepc;

      CSR_MCAUSE    : rdata = 32'd11;
      CSR_MVENDORID : rdata = 32'h79737978;
      CSR_MARCHID   : rdata = 32'h015fdeeb;

      default: rdata = 32'b0;
    endcase
  end

  // -------------------- CONTROL --------------------
  assign ifu_flush = 

endmodule
