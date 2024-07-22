module ysyx_23060203_EXU_old (
  input clock, reset,

  // 跳转输出
  output reg jump_flush, // 分支预测错误，需要冲刷流水线
  output [31:0] jump_dnpc,

  // fence.i
  output fencei,

  // 访存AXI接口
  axi_if.out mem_r,
  axi_if.out mem_w,

  // GPR forwarding
  output [4:0] exu_rd,
  output [31:0] exu_gpr_wdata,
  // 将要修改的CSR地址
  output [11:0] exu_csr_waddr,

  // 上游IDU输入
  output in_ready,
  input in_valid,
  input [31:0] in_pc,
  input [31:0] in_val_a,
  input [31:0] in_val_b,
  input [31:0] in_val_c,
  input        in_alu_src,
  input [2:0]  in_alu_funct,
  input        in_alu_sw,
  input [4:0]  in_rd,
  input        in_rd_src,
  input [3:0]  in_ls,
  input [2:0]  in_goto,
  input [1:0]  in_csrw,
  input        in_fencei,

  // 下游WBU输出
  input out_ready,
  output out_valid,
  output [4:0] out_gpr_waddr,
  output [31:0] out_gpr_wdata,
  output out_csr_wen,
  output [11:0] out_csr_waddr,
  output [31:0] out_csr_wdata

  `ifndef SYNTHESIS
    ,
    output [31:0] out_pc,
    input [31:0] in_inst,
    output [31:0] out_inst,
    output [31:0] out_dnpc
  `endif
);

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_HOLD,

    ST_LOAD_REQ,
    ST_LOAD_RESP,

    ST_STORE_REQ,
    ST_STORE_ADDR,
    ST_STORE_DATA,
    ST_STORE_RESP
  } state_t;

  state_t state, state_next;
  wire st_idle = state == ST_IDLE;
  wire st_hold = state == ST_HOLD;

  reg [31:0] pc, pc_next;
  reg [31:0] val_a, val_a_next;
  reg [31:0] val_b, val_b_next;
  reg [31:0] val_c, val_c_next;
  reg        alu_src, alu_src_next;
  reg [2:0]  alu_funct, alu_funct_next;
  reg        alu_sw, alu_sw_next;
  reg [4:0]  rd, rd_next;
  reg        rd_src, rd_src_next;
  reg [3:0]  ls, ls_next;
  reg [2:0]  goto, goto_next;
  reg [1:0]  csrw, csrw_next;
  `ifndef SYNTHESIS
    reg [31:0] inst, inst_next;
  `endif

  reg [31:0] load_val, load_val_next;

  always @(posedge clock) begin
    if (reset) begin
      state <= ST_IDLE;
    end else begin
      state <= state_next;
      pc <= pc_next;
      val_a <= val_a_next;
      val_b <= val_b_next;
      val_c <= val_c_next;
      alu_src <= alu_src_next;
      alu_funct <= alu_funct_next;
      alu_sw <= alu_sw_next;
      rd <= rd_next;
      rd_src <= rd_src_next;
      ls <= ls_next;
      goto <= goto_next;
      csrw <= csrw_next;
      load_val <= load_val_next;
      `ifndef SYNTHESIS
        inst <= inst_next;
      `endif
    end
  end

  assign in_ready = st_idle | (st_hold & out_ready);

  always_comb begin
    state_next = state;
    pc_next = pc;
    val_a_next = val_a;
    val_b_next = val_b;
    val_c_next = val_c;
    alu_src_next = alu_src;
    alu_funct_next = alu_funct;
    alu_sw_next = alu_sw;
    rd_next = rd;
    rd_src_next = rd_src;
    ls_next = ls;
    goto_next = goto;
    csrw_next = csrw;
    load_val_next = load_val;
    `ifndef SYNTHESIS
      inst_next = inst;
    `endif

    if (in_valid & in_ready) begin // input
      pc_next = in_pc;
      val_a_next = in_val_a;
      val_b_next = in_val_b;
      val_c_next = in_val_c;
      alu_src_next = in_alu_src;
      alu_funct_next = in_alu_funct;
      alu_sw_next = in_alu_sw;
      rd_next = in_rd;
      rd_src_next = in_rd_src;
      ls_next = in_ls;
      goto_next = in_goto;
      csrw_next = in_csrw;
      `ifndef SYNTHESIS
        inst_next = in_inst;
      `endif
      if (|in_ls) begin // 有内存操作
        if (in_ls[3]) begin
          state_next = ST_LOAD_REQ;
        end else begin
          state_next = ST_STORE_REQ;
        end
      end else begin
        state_next = ST_HOLD;
      end
    end

    case (state)
      ST_IDLE: begin
        if (in_valid) ; // input
      end
      ST_HOLD: begin
        if (out_ready) begin
          if (in_valid) begin
            ; // input
          end else begin
            state_next = ST_IDLE;
          end
        end
      end

      ST_LOAD_REQ: begin
        if (mem_r.arready) begin
          state_next = ST_LOAD_RESP;
        end
      end
      ST_LOAD_RESP: begin
        if (mem_r.rvalid) begin
          load_val_next = mem_rdata;
          state_next = ST_HOLD;
        end
      end

      ST_STORE_REQ: begin
        if (mem_w.awready & mem_w.wready) begin
          state_next = ST_STORE_RESP;
        end else if (mem_w.awready) begin
          state_next = ST_STORE_DATA;
        end else if (mem_w.wready) begin
          state_next = ST_STORE_ADDR;
        end
      end
      ST_STORE_ADDR: begin
        if (mem_w.awready) begin
          state_next = ST_STORE_RESP;
        end
      end
      ST_STORE_DATA: begin
        if (mem_w.wready) begin
          state_next = ST_STORE_RESP;
        end
      end
      ST_STORE_RESP: begin
        if (mem_w.bvalid) begin
          state_next = ST_HOLD;
        end
      end

      default: ;
    endcase
  end

  assign out_valid = st_hold;

  `ifndef SYNTHESIS
    assign out_pc = pc;
    assign out_inst = inst;
  `endif

  // -------------------- fence.i --------------------
  assign fencei = st_hold & in_fencei;

  // -------------------- ALU --------------------
  wire [31:0] alu_a = alu_src ? pc : val_a;
  wire [31:0] alu_b = val_b;
  wire [31:0] alu_val;
  ysyx_23060203_ALU alu (
    .alu_a(alu_a), .alu_b(alu_b),
    .funct(alu_funct), .sw(alu_sw),
    .val(alu_val)
  );

  // -------------------- LOAD --------------------
  assign mem_r.arvalid = state == ST_LOAD_REQ;
  assign mem_r.araddr = alu_val;
  assign mem_r.arid = 4'b0;
  assign mem_r.arlen = 8'b0;
  assign mem_r.arsize = {1'b0, ls[1:0]};
  assign mem_r.arburst = 2'b0;
  assign mem_r.rready = state == ST_LOAD_RESP;

  wire [63:0] mem_rdata_raw = mem_r.rdata >> {alu_val[2:0], 3'b0};
  reg [31:0] mem_rdata;
  always_comb begin
    case (ls[1:0])
      2'b00: mem_rdata = {{24{mem_rdata_raw[7]  & ls[2]}}, mem_rdata_raw[7:0] };
      2'b01: mem_rdata = {{16{mem_rdata_raw[15] & ls[2]}}, mem_rdata_raw[15:0]};
      default: mem_rdata = mem_rdata_raw[31:0];
    endcase
  end

  // -------------------- STORE --------------------
  wire st_store_req = state == ST_STORE_REQ;
  wire st_store_addr = state == ST_STORE_ADDR;
  wire st_store_data = state == ST_STORE_DATA;

  assign mem_w.awvalid = st_store_req | st_store_addr;
  assign mem_w.awaddr = alu_val;
  assign mem_w.awid = 4'b0;
  assign mem_w.awlen = 8'b0;
  assign mem_w.awsize = {1'b0, ls[1:0]};
  assign mem_w.awburst = 2'b0;

  wire [63:0] mem_wdata = {32'b0, val_c} << {alu_val[2:0], 3'b0};
  reg [3:0] mem_wstrb_raw;
  always_comb begin
    case (ls[1:0])
      2'b00: mem_wstrb_raw = 4'b0001;
      2'b01: mem_wstrb_raw = 4'b0011;
      2'b10: mem_wstrb_raw = 4'b1111;
      default: mem_wstrb_raw = 4'b0000;
    endcase
  end
  wire [7:0] mem_wstrb = {4'b0, mem_wstrb_raw} << alu_val[2:0];

  assign mem_w.wvalid = st_store_req | st_store_data;
  assign mem_w.wdata = mem_wdata;
  assign mem_w.wstrb = mem_wstrb;
  assign mem_w.wlast = 1'b1;

  assign mem_w.bready = state == ST_STORE_RESP;

  // -------------------- 跳转 --------------------
  wire alu_val_any = |alu_val;
  reg jump_en;
  always_comb begin
    case (goto)
      3'b000 : jump_en = 0;
      3'b100 : jump_en = alu_val_any;
      3'b101 : jump_en = ~alu_val_any;
      default: jump_en = 1;
    endcase
  end

  reg [31:0] dnpc_a, dnpc_b;
  always_comb begin
    case (goto)
      3'b010, 3'b011 : dnpc_a = val_a;
      default        : dnpc_a = pc;
    endcase

    case (goto)
      3'b011  : dnpc_b = 32'h0;
      default : dnpc_b = val_c;
    endcase
  end
  wire [31:0] dnpc_c = dnpc_a + (jump_en ? dnpc_b : 32'h4);

  // TEMP: 当前分支预测是btfnt(仅branch指令)
  assign jump_flush = st_hold & (jump_en ^ (goto[2] & val_c[31]));
  assign jump_dnpc = {dnpc_c[31:1], 1'b0};

  `ifndef SYNTHESIS
    assign out_dnpc = jump_dnpc;
  `endif

  // -------------------- GPR写回 --------------------
  assign out_gpr_waddr = rd;
  assign out_gpr_wdata = ls[3] ? (
    load_val
  ) : (
    rd_src ? val_a : alu_val
  );

  assign exu_rd = rd & {5{~st_idle}};
  assign exu_gpr_wdata = out_gpr_wdata;

  // -------------------- CSR写回 --------------------
  assign out_csr_wen = |csrw;
  assign out_csr_waddr = &csrw ? 12'h0 : val_c[11:0];
  assign out_csr_wdata = csrw[1] ? val_b : alu_val;
  // ebreak被标记为对0号CSR的有效写入操作

  assign exu_csr_waddr = out_csr_waddr & {12{~st_idle & out_csr_wen}};

  // -------------------- 性能计数器 --------------------
`ifndef SYNTHESIS
  always @(posedge clock) if (~reset) begin
    if (out_ready & out_valid) begin
      perf_event(PERF_EXU_INST);
    end
    if (jump_flush) begin
      perf_event(PERF_EXU_FLUSH);
    end
    case (state)
      ST_IDLE: perf_event(PERF_EXU_IDLE);
      ST_LOAD_REQ, ST_LOAD_RESP:
               perf_event(PERF_LSU_MEMR);
      ST_STORE_REQ, ST_STORE_ADDR, ST_STORE_DATA, ST_STORE_RESP:
               perf_event(PERF_LSU_MEMW);
      default: ;
    endcase
    if (mem_r.rready & mem_r.rvalid) begin
      event_mem_read(alu_val, {29'b0, mem_r.arsize}, mem_rdata);
    end
    if (mem_w.awready & mem_w.awvalid) begin
      event_mem_write(alu_val, {29'b0, mem_w.awsize}, val_c);
    end
  end
`endif

endmodule
