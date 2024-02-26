module top(
  input rstn, clk,

  // 用驱动程序控制的指令内存
  output [31:0] inst_mem_addr,
  input [31:0] inst_mem_data
);
  wire reg_wen;
  wire [4:0] reg_waddr;
  wire [31:0] reg_wdata;
  wire [4:0] reg_raddr;
  wire [31:0] reg_rdata;
  ysyx_23060203_RegFile RegFile (
    .clk(clk),

    .wen(reg_wen),
    .wdata(reg_wdata),
    .waddr(reg_waddr),

    .raddr(reg_raddr),
    .rdata(reg_rdata)
  );

  wire [31:0] pc, next_pc;
  ysyx_23060203_PC PC (
    .rstn(rstn), .clk(clk),

    .pc(pc), .next_pc(next_pc),

    .dnpc_en(0),
    .dnpc(32'b0)
  );

  wire [31:0] inst;
  ysyx_23060203_IFU IFU (
    .rstn(rstn), .clk(clk),

    .next_pc(next_pc), .inst(inst),

    .inst_mem_addr(inst_mem_addr),
    .inst_mem_data(inst_mem_data)
  );

  wire [4:0] rd;
  wire [31:0] src1, imm;
  ysyx_23060203_IDU IDU (
    .inst(inst),

    .rd(rd), .src1(src1), .imm(imm),

    .reg_raddr(reg_raddr),
    .reg_rdata(reg_rdata)
  );

  ysyx_23060203_EXU EXU (
    .rd(rd), .src1(src1), .imm(imm),

    .reg_wen(reg_wen),
    .reg_waddr(reg_waddr),
    .reg_wdata(reg_wdata)
  );
endmodule
