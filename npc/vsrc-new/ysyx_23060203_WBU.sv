module ysyx_23060203_WBU (
  input clock, reset,

  // GPR
  output gpr_wen, // 写入使能
  output [4:0] gpr_waddr, // 写入地址
  output [31:0] gpr_wdata, // 写入数据

  // CSR
  input csr_wen, // 写入使能
  input [11:0] csr_waddr, // 写入地址
  input [31:0] csr_wdata, // 写入数据

  // 上游EXU输入
  output in_ready,
  input in_valid,
  input in_gpr_wen,
  input [4:0] in_gpr_waddr,
  input [31:0] in_gpr_wdata,
  input in_csr_wen,
  input [11:0] in_csr_waddr,
  input [31:0] in_csr_wdata

  `ifndef SYNTHESIS
    ,
    input [31:0] in_pc,
    input [31:0] in_inst
  `endif
);

  assign in_ready = 1;

  assign gpr_wen = in_valid & in_gpr_wen;
  assign gpr_waddr = in_gpr_waddr;
  assign gpr_wdata = in_gpr_wdata;

  assign csr_wen = in_valid & in_csr_wen;
  assign csr_waddr = in_csr_waddr;
  assign csr_wdata = in_csr_wdata;

  `ifndef SYNTHESIS
    reg db_valid;
    reg [31:0] db_pc, dp_inst;
    always @(posedge clock) begin
      if (reset) begin
        db_valid <= 0;
      end else begin
        db_valid <= in_valid;
        db_pc <= in_pc;
        db_inst <= in_inst;
        if (csr_wen & ~(|csr_waddr)) begin // ebreak
          halt();
        end
      end

      if (db_valid) inst_complete(db_pc, db_inst);
    end
  `endif
endmodule
