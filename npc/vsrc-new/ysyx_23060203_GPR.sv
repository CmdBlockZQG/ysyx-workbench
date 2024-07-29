module ysyx_23060203_GPR (
  input clock, reset,

  // write
  input        wen,   // 写入使能
  input [ 4:0] waddr, // 写入地址
  input [31:0] wdata, // 写入数据

  // forwarding
  input [ 4:0] exu_rd,  // 0表示无GPR写入
  input [31:0] exu_data,

  input [ 4:0] lsu_rd,
  input [31:0] lsu_data,
  input        lsu_data_valid, // lsu是否已经取出数据

  // read
  input [4:0] raddr1,  // 读出地址
  output reg rvalid1, // 数据是否可用
  output reg [31:0] rdata1,  // 读出数据

  input [4:0] raddr2,  // 读出地址
  output reg rvalid2, // 数据是否可用
  output reg [31:0] rdata2   // 读出数据
);

  parameter NR_REG = 16;

  // -------------------- WRITE --------------------
  reg [31:0] r [1:NR_REG-1]/*verilator public*/;

  always @(posedge clock) begin
    if (~reset & wen & (|waddr)) begin
      r[waddr] <= wdata;
    end
  end

  // -------------------- READ --------------------

  always_comb begin
    priority case (raddr1)
      5'b0: begin
        rvalid1 = 1;
        rdata1 = 0;
      end
      exu_rd: begin
        rvalid1 = 1;
        rdata1 = exu_data;
      end
      lsu_rd: begin
        rvalid1 = lsu_data_valid;
        rdata1 = lsu_data;
      end
      default: begin
        rvalid1 = 1;
        rdata1 = r[rdata1];
      end
    endcase
  end

  always_comb begin
    priority case (raddr2)
      5'b0: begin
        rvalid2 = 1;
        rdata2 = 0;
      end
      exu_rd: begin
        rvalid2 = 1;
        rdata2 = exu_data;
      end
      lsu_rd: begin
        rvalid2 = lsu_data_valid;
        rdata2 = lsu_data;
      end
      default: begin
        rvalid2 = 1;
        rdata2 = r[rdata2];
      end
    endcase
  end

endmodule
