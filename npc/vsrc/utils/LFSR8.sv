module LFSR8 (
  input       clk,
  input       rstn, // 同步复位
  input       s, // 置数
  input [7:0] in,  // 置数输入

  output reg [7:0] out
);
  always @(posedge clk) begin
    if (~rstn) begin
      out <= 0;
    end else if (s) begin
      out <= in;
    end else begin
      out <= {(out[4] ^ out[3] ^ out[2] ^ out[0]), out[7:1]};
    end
  end
endmodule
