module ysyx_23060203_MemArb (
  input clock, reset,

  axi_if.in ifu_r,
  axi_if.in lsu_r,

  axi_if.out ram_r
);

  // 读仲裁器，LSU优先

  typedef enum {
    ST_IDLE,
    ST_IFU,
    ST_LSU,
    ST_TMP_REQ,
    ST_TMP_RESP
  } state_t;
  wire st_idle = state == ST_IDLE;

  state_t state, state_next;
  reg tmp, tmp_next; // 是否有暂存的ifu请求
  reg [31:0] tmp_raddr, tmp_raddr_next; // 暂存的ifu请求地址

  always @(posedge clock) begin
    if (reset) begin
      state <= ST_IDLE;
      tmp <= 0;
      tmp_raddr <= 0;
    end else begin
      state <= state_next;
      tmp <= tmp_next;
      tmp_raddr <= tmp_raddr_next;
    end
  end

  wire rhs = ram_r.rready & ram_r.rvalid & ram_r.rlast;
  always_comb begin
    state_next = state;
    tmp_next = tmp;
    tmp_raddr_next = tmp_raddr;
    case (state)
      ST_IDLE: begin
        if (ram_r.arready) begin
          if (ifu_r.arvalid & lsu_r.arvalid) begin // 同时握手
            state_next = ST_LSU;
            tmp_next = 1;
            tmp_raddr_next = ifu_r.araddr;
          end else if (ifu_r.arvalid) begin // ifu握手
            state_next = ST_IFU;
          end else if (lsu_r.arvalid) begin // lsu握手
            state_next = ST_LSU;
          end
        end
      end
      ST_IFU: begin
        if (rhs) begin
          state_next = ST_IDLE;
        end
      end
      ST_LSU: begin
        if (rhs) begin
          if (tmp) begin
            state_next = ST_TMP_REQ;
          end else begin
            state_next = ST_IDLE;
          end
        end
      end
      ST_TMP_REQ: begin
        tmp_next = 0;
        if (ram_r.arready) begin
          state_next = ST_TMP_RESP;
        end
      end
      ST_TMP_RESP: begin
        if (rhs) begin
          state_next = ST_IDLE;
        end
      end
      default: ;
    endcase
  end

  // ar channel
  assign ifu_r.arready = st_idle & ram_r.arready;
  assign lsu_r.arready = st_idle & ram_r.arready;

  always_comb begin
    ram_r.arvalid = 0;
    ram_r.araddr = 32'b0;
    ram_r.arid = 4'b0;
    ram_r.arlen = 8'b0;
    ram_r.arsize = 3'b0;
    ram_r.arburst = 2'b0;
    case (state)
      ST_IDLE: begin
        ram_r.arvalid = ifu_r.arvalid | lsu_r.arvalid;
        if (lsu_r.arvalid) begin
          ram_r.araddr = lsu_r.araddr;
          ram_r.arid = lsu_r.arid;
          ram_r.arlen = lsu_r.arlen;
          ram_r.arsize = lsu_r.arsize;
          ram_r.arburst = lsu_r.arburst;
        end else if (ifu_r.arvalid) begin
          ram_r.araddr = ifu_r.araddr;
          ram_r.arid = ifu_r.arid;
          ram_r.arlen = ifu_r.arlen;
          ram_r.arsize = ifu_r.arsize;
          ram_r.arburst = ifu_r.arburst;
        end
      end
      ST_TMP_REQ: begin
        ram_r.arvalid = 1;
        ram_r.araddr = tmp_raddr;
        // TEMP: 假设IFU请求的参数固定
        ram_r.arid = 4'b0;
        ram_r.arlen = 8'b0;
        ram_r.arsize = 3'b010;
        ram_r.arburst = 2'b0;
      end
      default: ;
    endcase
  end

  // r channel
  always_comb begin
    ram_r.rready = 0;
    lsu_r.rvalid = 0;
    ifu_r.rvalid = 0;
    case (state)
      ST_LSU: begin
        ram_r.rready = lsu_r.rready;
        lsu_r.rvalid = ram_r.rvalid;
      end
      ST_IFU, ST_TMP_RESP: begin
        ram_r.rready = ifu_r.rready;
        ifu_r.rvalid = ram_r.rvalid;
      end
      default: ;
    endcase
  end

  assign lsu_r.rresp = ram_r.rresp;
  assign lsu_r.rdata = ram_r.rdata;
  assign lsu_r.rlast = ram_r.rlast;
  assign lsu_r.rid = ram_r.rid;
  assign ifu_r.rresp = ram_r.rresp;
  assign ifu_r.rdata = ram_r.rdata;
  assign ifu_r.rlast = ram_r.rlast;
  assign ifu_r.rid = ram_r.rid;

endmodule
