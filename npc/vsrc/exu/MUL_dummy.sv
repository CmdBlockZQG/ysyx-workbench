module MUL_dummy (
  input clock, reset,

  input flush,

  output in_ready,
  input in_valid,
  input [1:0] in_sign,
  input [31:0] in_a, in_b,

  input out_ready,
  output out_valid,
  output [63:0] out_prod
);
  assign in_ready = 1;
  assign out_valid = 1;
  assign out_prod = 0;
endmodule
