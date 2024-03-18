`include "interface/axi.sv"

module UART (
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
      uart_putch(write.wdata[7:0]);
      write.bvalid <= 1;
    end
    if (write.bvalid & write.bready) begin
      write.bvalid <= 0;
    end
  end end

endmodule
