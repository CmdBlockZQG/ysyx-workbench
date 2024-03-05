module top(
  input rstn, clk
);

  wire [31:0] reg_rdata1, reg_rdata2;
  ysyx_23060203_RegFile RegFile (
    .rstn(rstn), .clk(clk),
    // 写
    .wen(reg_wen),
    .waddr(reg_waddr),
    .wdata(reg_wdata),
    // 读
    .raddr1(reg_raddr1),
    .rdata1(reg_rdata1),
    .raddr2(reg_raddr2),
    .rdata2(reg_rdata2)
  );


  wire [31:0] csr_rdata;
  ysyx_23060203_CSR CSR (
    .rstn(rstn), .clk(clk),

    .raddr(csr_raddr), .rdata(csr_rdata),

    .wen1(csr_wen1),
    .waddr1(csr_waddr1), .wdata1(csr_wdata1),
    .wen2(csr_wen2),
    .waddr2(csr_waddr2), .wdata2(csr_wdata2)
  );


  wire [31:0] pc/*verilator public*/;
  wire [31:0] next_pc/*verilator public*/;
  ysyx_23060203_PC PC (
    .rstn(rstn), .clk(clk),
    // 连接EXU输出，控制跳转
    .inc(pc_inc),
    .ovrd(pc_ovrd),
    .ovrd_addr(pc_ovrd_addr),
    // 输出
    .next_pc(next_pc), .pc(pc)
  );


  wire [31:0] inst/*verilator public*/;
  ysyx_23060203_IFU IFU (
    .rstn(rstn), .clk(clk),
    // 连接PC输入
    .next_pc(next_pc),
    // 输出
    .inst(inst)
  );


  wire [4:0] reg_raddr1, reg_raddr2;

  wire [11:0] csr_raddr;

  wire [31:0] alu_a, alu_b;
  wire [2:0] alu_funct;
  wire alu_funcs;

  wire [4:0] opcode;
  wire [2:0] funct;
  wire [4:0] rd;
  wire [31:0] src1, src2, imm;
  wire [31:0] csr;

  ysyx_23060203_IDU IDU (
    .inst(inst), .pc(pc),
    // 连接寄存器文件
    .reg_raddr1(reg_raddr1), .reg_rdata1(reg_rdata1),
    .reg_raddr2(reg_raddr2), .reg_rdata2(reg_rdata2),
    // 连接CSR读端口
    .csr_raddr(csr_raddr), .csr_rdata(csr_rdata),
    // 产生ALU输入
    .alu_a(alu_a), .alu_b(alu_b),
    .alu_funct(alu_funct), .alu_funcs(alu_funcs),
    // 产生EXU输入
    .opcode(opcode), .funct(funct),
    .rd(rd),
    .src1(src1), .src2(src2), .imm(imm),
    .csr(csr)
  );


  wire [31:0] alu_val;
  ysyx_23060203_ALU ALU (
    .alu_a(alu_a), .alu_b(alu_b),
    .funct(alu_funct), .funcs(alu_funcs),
    // 输出
    .val(alu_val)
  );


  wire reg_wen;
  wire [4:0] reg_waddr;
  wire [31:0] reg_wdata;

  wire mem_ren;
  wire [2:0] mem_rfunc;
  wire [31:0] mem_raddr;
  wire mem_wen;
  wire [2:0] mem_wfunc;
  wire [31:0] mem_waddr;
  wire [31:0] mem_wdata;

  wire pc_ovrd;
  wire [31:0] pc_inc, pc_ovrd_addr;
  wire csr_wen1, csr_wen2;
  wire [11:0] csr_waddr1, csr_waddr2;
  wire [31:0] csr_wdata1, csr_wdata2;
  ysyx_23060203_EXU EXU (
    // 译码结果
    .opcode(opcode), .funct(funct),
    .rd(rd),
    .src1(src1), .src2(src2), .imm(imm),
    .csr(csr),
    // alu结果
    .alu_val(alu_val),
    // 寄存器写
    .reg_wen(reg_wen),
    .reg_waddr(reg_waddr),
    .reg_wdata(reg_wdata),
    // 连接访存模块
    .mem_ren(mem_ren),
    .mem_rfunc(mem_rfunc),
    .mem_raddr(mem_raddr),
    .mem_rdata(mem_rdata),
    .mem_wen(mem_wen),
    .mem_wfunc(mem_wfunc),
    .mem_waddr(mem_waddr),
    .mem_wdata(mem_wdata),
    // 连接CSR写端口
    .csr_wen1(csr_wen1),
    .csr_waddr1(csr_waddr1), .csr_wdata1(csr_wdata1),
    .csr_wen2(csr_wen2),
    .csr_waddr2(csr_waddr2), .csr_wdata2(csr_wdata2),
    // 连接PC
    .pc_inc(pc_inc),
    .pc_ovrd(pc_ovrd),
    .pc_ovrd_addr(pc_ovrd_addr)
  );

  wire [31:0] mem_rdata;
  ysyx_23060203_MEM MEM (
    .rstn(rstn), .clk(clk),
    // 写
    .wen(mem_wen),
    .wfunc(mem_wfunc),
    .waddr(mem_waddr),
    .wdata(mem_wdata),
    // 读
    .ren(mem_ren),
    .rfunc(mem_rfunc),
    .raddr(mem_raddr),
    .rdata(mem_rdata)
  );
endmodule
