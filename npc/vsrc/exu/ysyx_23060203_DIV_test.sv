module ysyx_23060203_DIV_test (
  input clock, reset,

  input flush,

  output in_ready,
  input in_valid,
  input in_sign,
  input [31:0] in_a, in_b,

  input out_ready,
  output out_valid,
  output [31:0] out_quot,
  output [31:0] out_rem
);

  wire as = in_a[31] & in_sign;
  wire bs = in_b[31] & in_sign;

  wire [31:0] a = ({32{as}} ^ in_a) + {31'b0, as};
  wire [31:0] b = ({32{bs}} ^ in_b) + {31'b0, bs};

  wire qs = (in_a[31] ^ in_b[31]) & in_sign;
  wire rs = in_a[31] & in_sign;

  wire [31:0] q = a / b;
  wire [31:0] r = a - (q * b);

  assign out_quot = ({32{qs}} ^ q) + {31'b0, qs};
  assign out_rem  = ({32{rs}} ^ r) + {31'b0, rs};

  assign in_ready = 1;
  assign out_valid = in_valid & ~flush;
endmodule
