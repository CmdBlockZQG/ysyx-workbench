module ysyx_23060203_CPU (
  input clk, rstn,

  axi_if.master io_master,
  axi_if.slave io_slave
);
  // SRAM sram (
  //   .rstn(rstn), .clk(clk),
  //   .read(sram_r), .write(sram_w)
  // );

  // UART uart (
  //   .rstn(rstn), .clk(clk),
  //   .write(uart_w)
  // );

  // CLINT clint (
  //   .rstn(rstn), .clk(clk),
  //   .read(clint_r)
  // );

  // axi_lite_r_if sram_r, clint_r;
  // axi_lite_w_if sram_w, uart_w;
  // ysyx_23060203_Xbar Xbar (
  //   .rstn(rstn), .clk(clk),
  //   .read(ram_r),
  //   .sram_r(sram_r), .clint_r(clint_r),
  //   .write(ram_w),
  //   .sram_w(sram_w), .uart_w(uart_w)
  // );

  // axi_lite_r_if ram_r;
  ysyx_23060203_MemArb MemArb (
    .rstn(rstn), .clk(clk),
    .ifu_r(ifu_mem_r), .lsu_r(lsu_mem_r),
    .ram_r(io_master)
  );

  wire [31:0] gpr_rdata1, gpr_rdata2;
  ysyx_23060203_GPR GPR (
    .rstn(rstn), .clk(clk),
    // 写
    .wen(gpr_wen),
    .waddr(gpr_waddr),
    .wdata(gpr_wdata),
    // 读
    .raddr1(gpr_raddr1),
    .rdata1(gpr_rdata1),
    .raddr2(gpr_raddr2),
    .rdata2(gpr_rdata2)
  );

  wire [31:0] csr_rdata;
  ysyx_23060203_CSR CSR (
    .rstn(rstn), .clk(clk),

    .raddr(csr_raddr), .rdata(csr_rdata),

    .wen1(csr_wen1), .wen2(csr_wen2),
    .waddr1(csr_waddr1), .wdata1(csr_wdata1),
    .waddr2(csr_waddr2), .wdata2(csr_wdata2)
  );

  axi_lite_r_if ifu_mem_r;
  wire [31:0] pc;
  wire [31:0] inst;
  decouple_if inst_if;
  ysyx_23060203_IFU IFU (
    .rstn(rstn), .clk(clk),
    .npc(npc),
    .pc(pc), .inst(inst), .inst_out(inst_if),
    .ram_r(ifu_mem_r)
  );

  // GPR
  wire [4:0] gpr_raddr1, gpr_raddr2;
  wire [11:0] csr_raddr;
  // ALU
  wire [31:0] alu_a, alu_b;
  wire [2:0] alu_funct;
  wire alu_funcs;
  // EXU
  wire [4:0] opcode;
  wire [2:0] funct;
  wire [4:0] rd;
  wire [31:0] src1, src2, imm, csr;
  // decouple
  decouple_if id_if;
  ysyx_23060203_IDU  IDU (
    .pc(pc), .inst(inst), .inst_in(inst_if),
    // 寄存器读
    .gpr_raddr1(gpr_raddr1), .gpr_rdata1(gpr_rdata1),
    .gpr_raddr2(gpr_raddr2), .gpr_rdata2(gpr_rdata2),
    // CSR
    .csr_raddr(csr_raddr), .csr_rdata(csr_rdata),
    // ALU
    .alu_a(alu_a), .alu_b(alu_b),
    .alu_funct(alu_funct), .alu_funcs(alu_funcs),
    // EXU
    .opcode(opcode), .funct(funct),
    .rd(rd), .src1(src1), .src2(src2),
    .imm(imm), .csr(csr),

    .id_out(id_if)
  );

  // NPC
  wire [31:0] npc/*verilator public*/;
  // GPR CSR
  wire gpr_wen, csr_wen1, csr_wen2;
  wire [4:0] gpr_waddr;
  wire [11:0] csr_waddr1, csr_waddr2;
  wire [31:0] gpr_wdata, csr_wdata1, csr_wdata2;
  // MEM
  decouple_if mem_rreq;
  wire [2:0] mem_rfunc;
  wire [31:0] mem_raddr;
  decouple_if mem_wreq;
  wire [2:0] mem_wfunc;
  wire [31:0] mem_waddr, mem_wdata;
  ysyx_23060203_EXU EXU (
    .rstn(rstn), .clk(clk),

    .pc(pc), .opcode(opcode), .funct(funct),
    .rd(rd), .src1(src1), .src2(src2),
    .imm(imm), .csr(csr),
    .alu_a(alu_a), .alu_b(alu_b),
    .alu_funct(alu_funct), .alu_funcs(alu_funcs),
    .id_in(id_if),

    .npc(npc),

    .gpr_wen(gpr_wen),
    .gpr_waddr(gpr_waddr), .gpr_wdata(gpr_wdata),

    .csr_wen1(csr_wen1), .csr_wen2(csr_wen2),
    .csr_waddr1(csr_waddr1), .csr_waddr2(csr_waddr2),
    .csr_wdata1(csr_wdata1), .csr_wdata2(csr_wdata2),

    .mem_rreq(mem_rreq),
    .mem_raddr(mem_raddr), .mem_rfunc(mem_rfunc),
    .mem_rres(mem_rres), .mem_rdata(mem_rdata),

    .mem_wreq(mem_wreq), .mem_wfunc(mem_wfunc),
    .mem_waddr(mem_waddr), .mem_wdata(mem_wdata),
    .mem_wres(mem_wres)
  );

  decouple_if mem_rres, mem_wres;
  wire [31:0] mem_rdata;
  axi_lite_r_if lsu_mem_r;
  axi_lite_w_if ram_w;
  ysyx_23060203_LSU LSU (
    .rstn(rstn), .clk(clk),

    .rreq(mem_rreq),
    .raddr(mem_raddr), .rfunc(mem_rfunc),
    .rres(mem_rres), .rdata(mem_rdata),

    .wreq(mem_wreq), .wfunc(mem_wfunc),
    .waddr(mem_waddr), .wdata(mem_wdata),
    .wres(mem_wres),

    .ram_r(lsu_mem_r), .ram_w(io_master)
  );
endmodule
