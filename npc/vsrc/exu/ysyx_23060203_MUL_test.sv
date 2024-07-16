module ysyx_23060203_MUL_test (
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
  assign out_valid = in_valid & ~flush;
  wire signed [63:0] prod = $signed({in_sign[1] & in_a[31], in_a})
                          * $signed({in_sign[0] & in_b[31], in_b});
  assign out_prod = prod;
endmodule
