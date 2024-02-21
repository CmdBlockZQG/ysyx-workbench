module top(
  input rstn, clk,

  // 用驱动程序控制的指令内存
  output [31:0] inst_mem_addr,
  input [31:0] inst_mem_data
);
  wire reg_file_wen;
  wire [4:0] reg_file_waddr;
  wire [31:0] reg_file_wdata;
  wire [4:0] reg_file_raddr;
  wire [31:0] reg_file_rdata;
  ysyx_23060203_RegFile RegFile (
    .clk(clk),

    .wen(reg_file_wen),
    .wdata(reg_file_wdata),
    .waddr(reg_file_waddr),

    .raddr(reg_file_raddr),
    .rdata(reg_file_rdata)
  );

  wire [31:0] pc, next_pc;
  ysyx_23060203_PC PC (
    .rstn(rstn), .clk(clk),

    .pc(pc), .next_pc(next_pc),

    .dnpcen(0),
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

    .reg_file_raddr(reg_file_raddr),
    .reg_file_rdata(reg_file_rdata)
  );

  ysyx_23060203_EXU EXU (
    .rd(rd), .src1(src1), .imm(imm),

    .reg_file_wen(reg_file_wen),
    .reg_file_waddr(reg_file_waddr),
    .reg_file_wdata(reg_file_wdata)
  );
endmodule
