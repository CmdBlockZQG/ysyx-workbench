`include "interface/axi.sv"

module uart (
  input rstn, clk,

  axi_w_if.slave write
);
  `include "DPIC.sv"

  always @(posedge clk) begin
    if (~rstn) begin
      write.awready <= 1;
      write.wready <= 1;
      write.bvalid <= 0;
    end
  end

  always @(posedge clk) begin if (rstn) begin
    if (write.wvalid & write.wready) begin
    end
  end end

endmodule
