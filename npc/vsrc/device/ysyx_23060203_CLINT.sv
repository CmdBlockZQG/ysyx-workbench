module ysyx_23060203_CLINT (
  input clock, reset,

  // machine timer interrupt
  output reg mtip,
  input mtip_clear,

  axi_if.in read
);

  reg [63:0] mtime;

  always @(posedge clock)
  if (reset) begin
    mtime <= 0;
    mtip <= 0;
  end else begin
    mtime <= mtime + 1;

    if (&mtime[11:0]) begin
      mtip <= 1;
    end else if (mtip_clear) begin
      mtip <= 0;
    end
  end

  assign read.arready = 1;
  assign read.rvalid = 1;
  assign read.rresp = 0;
  assign read.rdata = read.araddr[2] ? mtime[63:32] : mtime[31:0];
  assign read.rlast = 1;
  assign read.rid = 0;
endmodule
