module ysyx_23060203_Xbar (
  input clock, reset,

  axi_if.in read,
  axi_if.out soc_r,
  axi_if.out clint_r
);

  typedef enum {
    ST_IDLE,
    ST_SOC,
    ST_CLINT
  } state_t;
  wire st_idle = state == ST_IDLE;
  wire st_soc = state == ST_SOC;
  wire st_clint = state == ST_CLINT;

  state_t state, state_next;

  always @(posedge clock) begin
    if (reset) begin
      state <= ST_IDLE;
    end else begin
      state <= state_next;
    end
  end

  wire req_clint;
  `ifdef YSYXSOC
    assign req_clint = (read.araddr[31:16] == 16'h0200);
  `else
    assign req_clint = (read.araddr[31:4] == 28'ha000004);
  `endif

  always_comb begin
    state_next = state;
    case (state)
      ST_IDLE: begin
        if (read.arready & read.arvalid) begin
          if (req_clint) begin
            state_next = ST_CLINT;
          end else begin
            state_next = ST_SOC;
          end
        end
      end
      ST_CLINT, ST_SOC: begin
        if (read.rready & read.rvalid & read.rlast) begin
          state_next = ST_IDLE;
        end
      end
      default: ;
    endcase
  end

  // ar channel
  assign read.arready = st_idle & (req_clint ? clint_r.arready : soc_r.arready);
  assign clint_r.arvalid = st_idle & req_clint & read.arvalid;
  assign clint_r.araddr = read.araddr;
  assign clint_r.arid = read.arid;
  assign clint_r.arlen = read.arlen;
  assign clint_r.arsize = read.arsize;
  assign clint_r.arburst = read.arburst;
  assign soc_r.arvalid = st_idle & ~req_clint & read.arvalid;
  assign soc_r.araddr = read.araddr;
  assign soc_r.arid = read.arid;
  assign soc_r.arlen = read.arlen;
  assign soc_r.arsize = read.arsize;
  assign soc_r.arburst = read.arburst;

  // r channel
  assign clint_r.rready = st_clint & read.rready;
  assign soc_r.rready = st_clint & read.rready;
  assign read.rvalid = (st_clint & clint_r.rvalid) | (st_soc & soc_r.rvalid);
  always_comb begin
    if (st_clint) begin
      read.rresp = clint_r.rresp;
      read.rdata = clint_r.rdata;
      read.rlast = clint_r.rlast;
      read.rid = clint_r.rid;
    end else begin
      read.rresp = soc_r.rresp;
      read.rdata = soc_r.rdata;
      read.rlast = soc_r.rlast;
      read.rid = soc_r.rid;
    end
  end

endmodule
