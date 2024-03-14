`include "interface/decouple.sv"

module ysyx_23060203_WBU (
  input rstn, clk,

  decouple_if.in wb_in,
  input [5:0] wb_addr,
  input [31:0] wb_data,

  output reg gpr_wen,
  output reg [5:0] gpr_waddr,
  output reg [31:0] gpr_wdata
);
  reg rstn_prev;
  always @(posedge clk) begin
    rstn_prev <= rstn;
    if (~rstn) begin
      wb_in.ready <= 0;
    end else if (rstn & ~rstn_prev) begin
      wb_in.ready <= 1;
    end

    gpr_wen <= wb_in.valid;
    gpr_waddr <= wb_addr;
    gpr_wdata <= wb_data;
  end
endmodule
