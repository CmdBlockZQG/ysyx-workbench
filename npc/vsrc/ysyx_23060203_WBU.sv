module ysyx_23060203_WBU (
  input clock, reset,

  // GPR
  output gpr_wen, // 写入使能
  output [4:0] gpr_waddr, // 写入地址
  output [31:0] gpr_wdata, // 写入数据

  // CSR
  input [11:0] csr_raddr, // 读取地址
  output reg [31:0] csr_rdata, // 读出数据

  // CSU
  output cs_flush,
  output reg [31:0] cs_dnpc,
  output flush_icache,

  // MMU
  output [31:0] csr_satp,
  output flush_tlb,

  // 上游EXU输入
  output in_ready,
  input in_valid,
  input [31:0] in_pc,
  input [4:0] in_gpr_waddr,
  input [31:0] in_gpr_wdata,
  input in_csr_wen,
  input [11:0] in_csr_waddr,
  input [31:0] in_csr_wdata,
  input in_exc,
  input in_ret,
  input in_fencei

  `ifndef SYNTHESIS
    ,
    input [31:0] in_inst,
    input [31:0] in_dnpc
  `endif
);

  assign in_ready = 1;

  // -------------------- GPR --------------------
  assign gpr_wen = in_valid;
  assign gpr_waddr = in_gpr_waddr;
  assign gpr_wdata = in_gpr_wdata;

  // -------------------- CSU --------------------
  reg valid;
  reg [31:0] pc;
  reg csr_wen, exc, ret, fencei;
  reg vmas_sw;

  always @(posedge clock)
  if (reset) begin
    valid <= 0;
  end else begin
    if (in_valid) begin
      valid <= 1;
      pc <= in_pc;
      csr_wen <= in_csr_wen;
      exc <= in_exc;
      ret <= in_ret;
      fencei <= in_fencei;
      vmas_sw <= in_csr_waddr == CSR_SATP;
    end else begin
      valid <= 0;
    end
  end

  assign cs_flush = valid & (csr_wen | exc | ret | fencei);
  assign flush_icache = 0;//valid & (fencei | vmas_sw);
  assign flush_tlb = valid & vmas_sw;

  always_comb begin
    case (1'b1)
      exc     : cs_dnpc = mtvec;
      ret     : cs_dnpc = mepc;
      default : cs_dnpc = pc + 4;
    endcase
  end

  // -------------------- CSR --------------------
  `include "def/csr.sv"
  reg [31:0] mstatus, mtvec, mepc, mcause, satp, mscratch;
  assign csr_satp = satp;

  always @(posedge clock)
  if (reset) begin
    mstatus <= 32'h1800;
    satp <= 0;
  end else begin
    if (in_valid) begin
      if (in_csr_wen) begin
        case (in_csr_waddr)
          CSR_MSTATUS  : mstatus  <= in_csr_wdata;
          CSR_MTVEC    : mtvec    <= in_csr_wdata;
          CSR_MEPC     : mepc     <= in_csr_wdata;
          CSR_MCAUSE   : mcause   <= in_csr_wdata;
          CSR_SATP     : satp     <= in_csr_wdata;
          CSR_MSCRATCH : mscratch <= in_csr_wdata;
          default: ;
        endcase
      end else if (in_exc) begin
        mepc <= in_pc;
        mcause <= 32'd11;
        mstatus <= {mstatus[31:8], mstatus[3], mstatus[6:4], 1'b0, mstatus[2:0]};
      end else if (in_ret) begin
        mstatus <= {mstatus[31:8], 1'b1, mstatus[6:4], mstatus[7], mstatus[2:0]};
      end
    end
  end

  always_comb begin
    case (csr_raddr)
      CSR_MSTATUS  : csr_rdata = mstatus;
      CSR_MTVEC    : csr_rdata = mtvec;
      CSR_MEPC     : csr_rdata = mepc;
      CSR_MCAUSE   : csr_rdata = mcause;
      CSR_SATP     : csr_rdata = satp;
      CSR_MSCRATCH : csr_rdata = mscratch;

      CSR_MVENDORID : csr_rdata = 32'h79737978;
      CSR_MARCHID   : csr_rdata = 32'h015fdeeb;

      default: csr_rdata = 32'b0;
    endcase
  end

  // -------------------- 仿真环境 --------------------
  `ifndef SYNTHESIS
    always @(posedge clock) begin
      if (in_valid) begin
        if (in_exc) inst_complete(mtvec, in_inst);
        else if (in_ret) inst_complete(mepc, in_inst);
        else inst_complete(in_dnpc, in_inst);
        if (in_exc & in_ret) halt(); // ebreak
      end
    end
  `endif
endmodule
