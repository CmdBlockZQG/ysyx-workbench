module DIV_dummy (
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
  assign in_ready = 1;
  assign out_valid = 1;
  assign out_quot = 0;
  assign out_rem = 0;
endmodule
