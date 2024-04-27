// removed module with interface ports: ysyx_23060203_CPU
// removed module with interface ports: ysyx_23060203_Xbar
// removed interface: decouple_if
// removed interface: axi_if
// removed interface: axi_lite_r_if
// removed interface: axi_lite_w_if
// removed module with interface ports: ysyx_23060203_LSU
// removed module with interface ports: ysyx_23060203_EXU
module ysyx_23060203_ALU (
	alu_a,
	alu_b,
	funct,
	funcs,
	val
);
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:4:3
	input [31:0] alu_a;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:5:3
	input [31:0] alu_b;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:7:3
	input [2:0] funct;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:8:3
	input funcs;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:10:3
	output reg [31:0] val;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:14:3
	localparam [2:0] ALU_LTS = 3'b010;
	localparam [2:0] ALU_LTU = 3'b011;
	wire binv = (funcs | (funct == ALU_LTS)) | (funct == ALU_LTU);
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:17:3
	wire [31:0] a = alu_a;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:18:3
	wire [31:0] b = alu_b ^ {32 {binv}};
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:19:3
	wire [31:0] bs = {27'b000000000000000000000000000, alu_b[4:0]};
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:21:3
	reg [31:0] e;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:22:3
	reg cf;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:23:3
	wire sf = e[31];
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:24:3
	wire of = (a[31] == b[31]) & (sf ^ a[31]);
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:26:3
	wire signed [31:0] sra = $signed(a) >>> $signed(bs);
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:28:3
	localparam [2:0] ALU_ADD = 3'b000;
	localparam [2:0] ALU_AND = 3'b111;
	localparam [2:0] ALU_OR = 3'b110;
	localparam [2:0] ALU_SHL = 3'b001;
	localparam [2:0] ALU_SHR = 3'b101;
	localparam [2:0] ALU_XOR = 3'b100;
	always @(*) begin
		// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:29:5
		cf = 0;
		// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:30:5
		case (funct)
			ALU_ADD, ALU_LTS, ALU_LTU:
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:31:34
				{cf, e} = (a + b) + {31'b0000000000000000000000000000000, binv};
			ALU_SHL:
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:32:16
				e = a << bs;
			ALU_XOR:
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:33:16
				e = a ^ b;
			ALU_SHR:
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:34:16
				e = (funcs ? sra : a >> bs);
			ALU_OR:
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:35:16
				e = a | b;
			ALU_AND:
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:36:16
				e = a & b;
			default:
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:37:16
				e = 32'b00000000000000000000000000000000;
		endcase
	end
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:41:3
	always @(*)
		// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:42:5
		case (funct)
			ALU_LTS:
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:43:16
				val = {31'b0000000000000000000000000000000, sf ^ of};
			ALU_LTU:
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:44:16
				val = {31'b0000000000000000000000000000000, !cf};
			default:
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_ALU.sv:45:16
				val = e;
		endcase
endmodule
module ysyx_23060203_CSR (
	rstn,
	clk,
	raddr,
	rdata,
	wen1,
	waddr1,
	wdata1,
	wen2,
	waddr2,
	wdata2
);
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:2:3
	input rstn;
	input clk;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:4:3
	input [11:0] raddr;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:5:3
	output reg [31:0] rdata;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:7:3
	input wen1;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:8:3
	input [11:0] waddr1;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:9:3
	input [31:0] wdata1;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:10:3
	input wen2;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:11:3
	input [11:0] waddr2;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:12:3
	input [31:0] wdata2;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:14:3
	reg [31:0] mstatus;
	reg [31:0] mtvec;
	reg [31:0] mepc;
	reg [31:0] mcause;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:17:3
	localparam [11:0] CSR_MARCHID = 12'hf12;
	localparam [11:0] CSR_MCAUSE = 12'h342;
	localparam [11:0] CSR_MEPC = 12'h341;
	localparam [11:0] CSR_MSTATUS = 12'h300;
	localparam [11:0] CSR_MTVEC = 12'h305;
	localparam [11:0] CSR_MVENDORID = 12'hf11;
	always @(*)
		// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:18:5
		case (raddr)
			CSR_MSTATUS:
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:19:21
				rdata = mstatus;
			CSR_MTVEC:
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:20:21
				rdata = mtvec;
			CSR_MEPC:
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:21:21
				rdata = mepc;
			CSR_MCAUSE:
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:22:21
				rdata = mcause;
			CSR_MVENDORID:
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:24:23
				rdata = 32'h79737978;
			CSR_MARCHID:
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:25:23
				rdata = 32'h015fdeeb;
			default:
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:27:21
				rdata = 32'b00000000000000000000000000000000;
		endcase
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:32:3
	always @(posedge clk)
		// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:33:5
		if (rstn) begin
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:34:7
			if (wen1)
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:35:9
				case (waddr1)
					CSR_MSTATUS:
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:36:25
						mstatus <= wdata1;
					CSR_MTVEC:
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:37:25
						mtvec <= wdata1;
					CSR_MEPC:
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:38:25
						mepc <= wdata1;
					CSR_MCAUSE:
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:39:25
						mcause <= wdata1;
					default:
						;
				endcase
			if (wen2)
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:44:9
				case (waddr2)
					CSR_MSTATUS:
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:45:25
						mstatus <= wdata2;
					CSR_MTVEC:
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:46:25
						mtvec <= wdata2;
					CSR_MEPC:
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:47:25
						mepc <= wdata2;
					CSR_MCAUSE:
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:48:25
						mcause <= wdata2;
					default:
						;
				endcase
		end
		else begin
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:53:7
			mstatus <= 32'h00001800;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:54:7
			mtvec <= 32'b00000000000000000000000000000000;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:55:7
			mepc <= 32'b00000000000000000000000000000000;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CSR.sv:56:7
			mcause <= 32'b00000000000000000000000000000000;
		end
endmodule
// removed module with interface ports: npc_RAM
// removed module with interface ports: ysyx_23060203_CLINT
module ysyx_23060203_GPR (
	rstn,
	clk,
	wen,
	waddr,
	wdata,
	raddr1,
	rdata1,
	raddr2,
	rdata2
);
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:1:28
	parameter integer NR_REG = 16;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:2:3
	input rstn;
	input clk;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:4:3
	input wen;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:5:3
	input [4:0] waddr;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:6:3
	input [31:0] wdata;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:8:3
	input [4:0] raddr1;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:9:3
	output wire [31:0] rdata1;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:10:3
	input [4:0] raddr2;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:11:3
	output wire [31:0] rdata2;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:13:3
	reg [31:0] rf [1:NR_REG - 1];
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:16:3
	assign rdata1 = (raddr1 == 5'b00000 ? 0 : rf[raddr1]);
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:17:3
	assign rdata2 = (raddr2 == 5'b00000 ? 0 : rf[raddr2]);
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:20:3
	integer i;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:21:3
	always @(posedge clk)
		// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:22:5
		if (rstn) begin
			begin
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:23:7
				if (wen && (waddr != 5'b00000))
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:24:9
					rf[waddr] <= wdata;
			end
		end
		else
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:28:7
			for (i = 1; i < NR_REG; i = i + 1)
				begin
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_GPR.sv:29:9
					rf[i] <= 0;
				end
endmodule
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/branch.sv:2:1
// removed ["BR_BEQ"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/branch.sv:3:1
// removed ["BR_BNE"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/branch.sv:4:1
// removed ["BR_BLT"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/branch.sv:5:1
// removed ["BR_BGE"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/branch.sv:6:1
// removed ["BR_BLTU"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/branch.sv:7:1
// removed ["BR_BGEU"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/csr.sv:2:1
// removed ["CSR_MSTATUS"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/csr.sv:3:1
// removed ["CSR_MTVEC"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/csr.sv:4:1
// removed ["CSR_MEPC"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/csr.sv:5:1
// removed ["CSR_MCAUSE"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/csr.sv:7:1
// removed ["CSR_MVENDORID"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/csr.sv:8:1
// removed ["CSR_MARCHID"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/csr.sv:10:1
// removed ["CSRF_RW"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/csr.sv:11:1
// removed ["CSRF_RS"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/csr.sv:12:1
// removed ["CSRF_RC"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/csr.sv:13:1
// removed ["CSRF_RWI"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/csr.sv:14:1
// removed ["CSRF_RSI"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/csr.sv:15:1
// removed ["CSRF_RCI"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/mem.sv:2:1
// removed ["LD_BS"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/mem.sv:3:1
// removed ["LD_HS"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/mem.sv:4:1
// removed ["LD_W"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/mem.sv:5:1
// removed ["LD_BU"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/mem.sv:6:1
// removed ["LD_HU"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/mem.sv:8:1
// removed ["ST_B"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/mem.sv:9:1
// removed ["ST_H"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/mem.sv:10:1
// removed ["ST_W"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/alu.sv:3:1
// removed ["ALU_ADD"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/alu.sv:4:1
// removed ["ALU_SHL"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/alu.sv:5:1
// removed ["ALU_LTS"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/alu.sv:6:1
// removed ["ALU_LTU"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/alu.sv:7:1
// removed ["ALU_XOR"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/alu.sv:8:1
// removed ["ALU_SHR"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/alu.sv:9:1
// removed ["ALU_OR"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/alu.sv:10:1
// removed ["ALU_AND"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/opcode.sv:2:1
// removed ["OP_LUI"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/opcode.sv:3:1
// removed ["OP_AUIPC"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/opcode.sv:4:1
// removed ["OP_JAL"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/opcode.sv:5:1
// removed ["OP_JALR"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/opcode.sv:6:1
// removed ["OP_BRANCH"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/opcode.sv:7:1
// removed ["OP_LOAD"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/opcode.sv:8:1
// removed ["OP_STORE"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/opcode.sv:9:1
// removed ["OP_CALRI"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/opcode.sv:10:1
// removed ["OP_CALRR"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/params/opcode.sv:11:1
// removed ["OP_SYS"]
module ysyx_23060203 (
	clock,
	reset,
	io_interrupt,
	io_master_awready,
	io_master_awvalid,
	io_master_awaddr,
	io_master_awid,
	io_master_awlen,
	io_master_awsize,
	io_master_awburst,
	io_master_wready,
	io_master_wvalid,
	io_master_wdata,
	io_master_wstrb,
	io_master_wlast,
	io_master_bready,
	io_master_bvalid,
	io_master_bresp,
	io_master_bid,
	io_master_arready,
	io_master_arvalid,
	io_master_araddr,
	io_master_arid,
	io_master_arlen,
	io_master_arsize,
	io_master_arburst,
	io_master_rready,
	io_master_rvalid,
	io_master_rresp,
	io_master_rdata,
	io_master_rlast,
	io_master_rid,
	io_slave_awready,
	io_slave_awvalid,
	io_slave_awaddr,
	io_slave_awid,
	io_slave_awlen,
	io_slave_awsize,
	io_slave_awburst,
	io_slave_wready,
	io_slave_wvalid,
	io_slave_wdata,
	io_slave_wstrb,
	io_slave_wlast,
	io_slave_bready,
	io_slave_bvalid,
	io_slave_bresp,
	io_slave_bid,
	io_slave_arready,
	io_slave_arvalid,
	io_slave_araddr,
	io_slave_arid,
	io_slave_arlen,
	io_slave_arsize,
	io_slave_arburst,
	io_slave_rready,
	io_slave_rvalid,
	io_slave_rresp,
	io_slave_rdata,
	io_slave_rlast,
	io_slave_rid
);
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:2:3
	input clock;
	input reset;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:3:3
	input io_interrupt;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:5:3
	input io_master_awready;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:6:3
	output wire io_master_awvalid;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:7:3
	output wire [31:0] io_master_awaddr;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:8:3
	output wire [3:0] io_master_awid;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:9:3
	output wire [7:0] io_master_awlen;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:10:3
	output wire [2:0] io_master_awsize;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:11:3
	output wire [1:0] io_master_awburst;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:12:3
	input io_master_wready;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:13:3
	output wire io_master_wvalid;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:14:3
	output wire [63:0] io_master_wdata;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:15:3
	output wire [7:0] io_master_wstrb;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:16:3
	output wire io_master_wlast;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:17:3
	output wire io_master_bready;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:18:3
	input io_master_bvalid;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:19:3
	input [1:0] io_master_bresp;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:20:3
	input [3:0] io_master_bid;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:21:3
	input io_master_arready;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:22:3
	output wire io_master_arvalid;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:23:3
	output wire [31:0] io_master_araddr;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:24:3
	output wire [3:0] io_master_arid;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:25:3
	output wire [7:0] io_master_arlen;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:26:3
	output wire [2:0] io_master_arsize;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:27:3
	output wire [1:0] io_master_arburst;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:28:3
	output wire io_master_rready;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:29:3
	input io_master_rvalid;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:30:3
	input [1:0] io_master_rresp;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:31:3
	input [63:0] io_master_rdata;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:32:3
	input io_master_rlast;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:33:3
	input [3:0] io_master_rid;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:35:3
	output wire io_slave_awready;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:36:3
	input io_slave_awvalid;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:37:3
	input [31:0] io_slave_awaddr;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:38:3
	input [3:0] io_slave_awid;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:39:3
	input [7:0] io_slave_awlen;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:40:3
	input [2:0] io_slave_awsize;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:41:3
	input [1:0] io_slave_awburst;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:42:3
	output wire io_slave_wready;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:43:3
	input io_slave_wvalid;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:44:3
	input [63:0] io_slave_wdata;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:45:3
	input [7:0] io_slave_wstrb;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:46:3
	input io_slave_wlast;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:47:3
	input io_slave_bready;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:48:3
	output wire io_slave_bvalid;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:49:3
	output wire [1:0] io_slave_bresp;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:50:3
	output wire [3:0] io_slave_bid;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:51:3
	output wire io_slave_arready;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:52:3
	input io_slave_arvalid;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:53:3
	input [31:0] io_slave_araddr;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:54:3
	input [3:0] io_slave_arid;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:55:3
	input [7:0] io_slave_arlen;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:56:3
	input [2:0] io_slave_arsize;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:57:3
	input [1:0] io_slave_arburst;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:58:3
	input io_slave_rready;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:59:3
	output wire io_slave_rvalid;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:60:3
	output wire [1:0] io_slave_rresp;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:61:3
	output wire [63:0] io_slave_rdata;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:62:3
	output wire io_slave_rlast;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:63:3
	output wire [3:0] io_slave_rid;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:143:3
	// expanded interface instance: io_master
	generate
		if (1) begin : io_master
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:3:3
			wire awvalid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:4:3
			reg awready;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:5:3
			wire [31:0] awaddr;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:6:3
			wire [3:0] awid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:7:3
			wire [7:0] awlen;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:8:3
			reg [2:0] awsize;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:9:3
			wire [1:0] awburst;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:10:3
			reg wready;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:11:3
			wire wvalid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:12:3
			wire [63:0] wdata;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:13:3
			wire [7:0] wstrb;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:14:3
			wire wlast;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:15:3
			wire bready;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:16:3
			reg bvalid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:17:3
			reg [1:0] bresp;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:18:3
			wire [3:0] bid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:20:3
			wire arready;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:21:3
			reg arvalid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:22:3
			wire [31:0] araddr;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:23:3
			wire [3:0] arid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:24:3
			wire [7:0] arlen;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:25:3
			wire [2:0] arsize;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:26:3
			wire [1:0] arburst;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:27:3
			wire rready;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:28:3
			reg rvalid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:29:3
			wire [1:0] rresp;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:30:3
			reg [63:0] rdata;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:31:3
			wire rlast;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:32:3
			wire [3:0] rid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:34:3
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:68:3
		end
	endgenerate
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:144:3
	// expanded interface instance: io_slave
	generate
		if (1) begin : io_slave
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:3:3
			wire awvalid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:4:3
			wire awready;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:5:3
			wire [31:0] awaddr;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:6:3
			wire [3:0] awid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:7:3
			wire [7:0] awlen;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:8:3
			wire [2:0] awsize;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:9:3
			wire [1:0] awburst;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:10:3
			wire wready;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:11:3
			wire wvalid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:12:3
			wire [63:0] wdata;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:13:3
			wire [7:0] wstrb;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:14:3
			wire wlast;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:15:3
			wire bready;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:16:3
			wire bvalid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:17:3
			wire [1:0] bresp;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:18:3
			wire [3:0] bid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:20:3
			wire arready;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:21:3
			wire arvalid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:22:3
			wire [31:0] araddr;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:23:3
			wire [3:0] arid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:24:3
			wire [7:0] arlen;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:25:3
			wire [2:0] arsize;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:26:3
			wire [1:0] arburst;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:27:3
			wire rready;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:28:3
			wire rvalid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:29:3
			wire [1:0] rresp;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:30:3
			wire [63:0] rdata;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:31:3
			wire rlast;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:32:3
			wire [3:0] rid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:34:3
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:68:3
		end
	endgenerate
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:146:3
	// expanded module instance: NPC_RAM
	generate
		if (1) begin : NPC_RAM
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:2:3
			wire rstn;
			wire clk;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:4:3
			// removed modport instance in
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:7:3
			reg waddr_valid_reg;
			reg wdata_valid_reg;
			always @(posedge clk)
				if (~rstn) begin
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:8:5
					ysyx_23060203.io_master.rvalid <= 0;
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:10:5
					ysyx_23060203.io_master.awready <= 1;
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:11:5
					ysyx_23060203.io_master.wready <= 1;
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:12:5
					ysyx_23060203.io_master.bvalid <= 0;
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:14:5
					waddr_valid_reg <= 0;
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:15:5
					wdata_valid_reg <= 0;
				end
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:18:3
			assign ysyx_23060203.io_master.arready = 1;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:19:3
			assign ysyx_23060203.io_master.rresp = 2'b00;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:20:3
			always @(posedge clk)
				if (rstn) begin
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:21:5
					if (ysyx_23060203.io_master.rvalid & ysyx_23060203.io_master.rready)
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:21:32
						ysyx_23060203.io_master.rvalid <= 0;
					if (ysyx_23060203.io_master.arvalid & ysyx_23060203.io_master.arready) begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:23:7
						ysyx_23060203.io_master.rvalid <= 1;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:24:7
						ysyx_23060203.io_master.rdata <= {2 {pmem_read(ysyx_23060203.io_master.araddr)}};
					end
				end
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:28:3
			wire waddr_handshake = ysyx_23060203.io_master.awready & ysyx_23060203.io_master.awvalid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:29:3
			reg [31:0] waddr_reg;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:30:3
			wire [31:0] waddr = (waddr_handshake ? ysyx_23060203.io_master.awaddr : waddr_reg);
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:31:3
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:32:3
			wire waddr_valid = waddr_handshake | waddr_valid_reg;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:34:3
			wire wdata_handshake = ysyx_23060203.io_master.wready & ysyx_23060203.io_master.wvalid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:35:3
			reg [63:0] wdata_reg;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:36:3
			reg [7:0] wmask_reg;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:37:3
			wire [63:0] wdata = (wdata_handshake ? ysyx_23060203.io_master.wdata : wdata_reg);
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:38:3
			wire [7:0] wmask = (wdata_handshake ? ysyx_23060203.io_master.wstrb : wmask_reg);
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:39:3
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:40:3
			wire wdata_valid = wdata_handshake | wdata_valid_reg;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:42:3
			wire write_en = waddr_valid & wdata_valid;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:44:3
			always @(posedge clk)
				if (rstn) begin
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:45:5
					if (waddr_handshake) begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:46:7
						waddr_reg <= ysyx_23060203.io_master.awaddr;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:47:7
						if (~write_en) begin
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:48:9
							waddr_valid_reg <= 1;
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:49:9
							ysyx_23060203.io_master.awready <= 0;
						end
					end
					if (wdata_handshake) begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:53:7
						wmask_reg <= ysyx_23060203.io_master.wstrb;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:54:7
						wdata_reg <= ysyx_23060203.io_master.wdata;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:55:7
						if (~write_en) begin
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:56:9
							wdata_valid_reg <= 1;
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:57:9
							ysyx_23060203.io_master.wready <= 0;
						end
					end
					if (write_en) begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:62:7
						pmem_write({waddr[31:3], 3'b000}, wdata[31:0], {4'b0000, wmask[3:0]});
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:63:7
						pmem_write({waddr[31:3], 3'b100}, wdata[63:32], {4'b0000, wmask[7:4]});
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:65:7
						ysyx_23060203.io_master.bresp <= 2'b00;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:66:7
						ysyx_23060203.io_master.bvalid <= 1;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:67:7
						ysyx_23060203.io_master.awready <= 1;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:68:7
						ysyx_23060203.io_master.wready <= 1;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:70:7
						waddr_valid_reg <= 0;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:71:7
						wdata_valid_reg <= 0;
					end
					if (ysyx_23060203.io_master.bvalid & ysyx_23060203.io_master.bready)
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/npc_RAM.sv:74:32
						ysyx_23060203.io_master.bvalid <= 0;
				end
		end
	endgenerate
	assign NPC_RAM.clk = clock;
	assign NPC_RAM.rstn = ~reset;
	// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203.sv:151:3
	// expanded module instance: NPC_CPU
	generate
		if (1) begin : NPC_CPU
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:2:3
			wire clk;
			wire rstn;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:4:3
			// removed modport instance io_master
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:5:3
			// removed modport instance io_slave
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:8:3
			wire [31:0] gpr_rdata1;
			wire [31:0] gpr_rdata2;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:9:3
			wire [4:0] gpr_raddr1;
			wire [4:0] gpr_raddr2;
			wire [4:0] gpr_waddr;
			wire [31:0] gpr_wdata;
			wire gpr_wen;
			ysyx_23060203_GPR GPR(
				.rstn(rstn),
				.clk(clk),
				.wen(gpr_wen),
				.waddr(gpr_waddr),
				.wdata(gpr_wdata),
				.raddr1(gpr_raddr1),
				.rdata1(gpr_rdata1),
				.raddr2(gpr_raddr2),
				.rdata2(gpr_rdata2)
			);
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:22:3
			wire [31:0] csr_rdata;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:23:3
			wire [11:0] csr_raddr;
			wire [11:0] csr_waddr1;
			wire [11:0] csr_waddr2;
			wire [31:0] csr_wdata1;
			wire [31:0] csr_wdata2;
			wire csr_wen1;
			wire csr_wen2;
			ysyx_23060203_CSR CSR(
				.rstn(rstn),
				.clk(clk),
				.raddr(csr_raddr),
				.rdata(csr_rdata),
				.wen1(csr_wen1),
				.wen2(csr_wen2),
				.waddr1(csr_waddr1),
				.wdata1(csr_wdata1),
				.waddr2(csr_waddr2),
				.wdata2(csr_wdata2)
			);
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:33:3
			// expanded interface instance: ifu_mem_r
			if (1) begin : ifu_mem_r
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:3:3
				wire awvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:4:3
				wire awready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:5:3
				wire [31:0] awaddr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:6:3
				wire [3:0] awid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:7:3
				wire [7:0] awlen;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:8:3
				wire [2:0] awsize;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:9:3
				wire [1:0] awburst;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:10:3
				wire wready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:11:3
				wire wvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:12:3
				wire [63:0] wdata;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:13:3
				wire [7:0] wstrb;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:14:3
				wire wlast;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:15:3
				wire bready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:16:3
				wire bvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:17:3
				wire [1:0] bresp;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:18:3
				wire [3:0] bid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:20:3
				wire arready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:21:3
				wire arvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:22:3
				reg [31:0] araddr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:23:3
				wire [3:0] arid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:24:3
				wire [7:0] arlen;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:25:3
				wire [2:0] arsize;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:26:3
				wire [1:0] arburst;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:27:3
				wire rready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:28:3
				wire rvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:29:3
				wire [1:0] rresp;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:30:3
				wire [63:0] rdata;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:31:3
				wire rlast;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:32:3
				wire [3:0] rid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:34:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:68:3
			end
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:34:3
			wire [31:0] pc;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:35:3
			wire [31:0] inst;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:36:3
			// expanded interface instance: inst_if
			if (1) begin : inst_if
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:2:3
				wire valid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:3:3
				wire ready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:5:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:10:3
			end
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:37:3
			wire [31:0] npc;
			// expanded module instance: IFU
			if (1) begin : IFU
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:2:3
				wire rstn;
				wire clk;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:5:3
				wire [31:0] npc;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:8:3
				reg [31:0] pc;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:9:3
				wire [31:0] inst;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:10:3
				// removed modport instance inst_out
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:13:3
				// removed modport instance ram_r
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:15:3
				assign ysyx_23060203.NPC_CPU.ifu_mem_r.arsize = 3'b010;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:17:3
				always @(posedge clk)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:18:5
					if (~rstn) begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:23:7
						pc <= 32'h80000000;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:24:7
						ysyx_23060203.NPC_CPU.ifu_mem_r.araddr <= 32'h80000000;
					end
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:30:3
				assign ysyx_23060203.NPC_CPU.inst_if.valid = ysyx_23060203.NPC_CPU.ifu_mem_r.rvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:31:3
				assign ysyx_23060203.NPC_CPU.ifu_mem_r.rready = ysyx_23060203.NPC_CPU.inst_if.ready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:32:3
				assign ysyx_23060203.NPC_CPU.ifu_mem_r.arvalid = ysyx_23060203.NPC_CPU.inst_if.ready & rstn;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:33:3
				assign inst = (ysyx_23060203.NPC_CPU.ifu_mem_r.araddr[2] ? ysyx_23060203.NPC_CPU.ifu_mem_r.rdata[63:32] : ysyx_23060203.NPC_CPU.ifu_mem_r.rdata[31:0]);
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:35:3
				always @(posedge clk)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:35:31
					if (rstn) begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:37:5
						if (ysyx_23060203.NPC_CPU.ifu_mem_r.arvalid & ysyx_23060203.NPC_CPU.ifu_mem_r.arready)
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:38:7
							pc <= ysyx_23060203.NPC_CPU.ifu_mem_r.araddr;
						if (ysyx_23060203.NPC_CPU.inst_if.valid & ysyx_23060203.NPC_CPU.inst_if.ready) begin
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:44:7
							ysyx_23060203.NPC_CPU.ifu_mem_r.araddr <= npc;
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:45:7
							if (inst == 32'h00100073)
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:46:9
								halt;
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IFU.sv:48:7
							inst_complete(pc, inst);
						end
					end
			end
			assign IFU.rstn = rstn;
			assign IFU.clk = clk;
			assign IFU.npc = npc;
			assign pc = IFU.pc;
			assign inst = IFU.inst;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:45:3
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:46:3
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:48:3
			wire [31:0] alu_a;
			wire [31:0] alu_b;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:49:3
			wire [2:0] alu_funct;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:50:3
			wire alu_funcs;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:52:3
			wire [4:0] opcode;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:53:3
			wire [2:0] funct;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:54:3
			wire [4:0] rd;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:55:3
			wire [31:0] src1;
			wire [31:0] src2;
			wire [31:0] imm;
			wire [31:0] csr;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:57:3
			// expanded interface instance: id_if
			if (1) begin : id_if
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:2:3
				wire valid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:3:3
				reg ready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:5:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:10:3
			end
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:58:3
			// expanded module instance: IDU
			if (1) begin : IDU
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:4:3
				wire [31:0] inst;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:5:3
				wire [31:0] pc;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:6:3
				// removed modport instance inst_in
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:9:3
				wire [4:0] gpr_raddr1;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:10:3
				wire [31:0] gpr_rdata1;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:11:3
				wire [4:0] gpr_raddr2;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:12:3
				wire [31:0] gpr_rdata2;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:15:3
				wire [11:0] csr_raddr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:16:3
				wire [31:0] csr_rdata;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:19:3
				reg [31:0] alu_a;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:20:3
				reg [31:0] alu_b;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:21:3
				reg [2:0] alu_funct;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:22:3
				wire alu_funcs;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:24:3
				wire [4:0] opcode;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:25:3
				wire [2:0] funct;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:26:3
				wire [4:0] rd;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:27:3
				wire [31:0] src1;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:28:3
				wire [31:0] src2;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:29:3
				reg [31:0] imm;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:30:3
				wire [31:0] csr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:32:3
				// removed modport instance id_out
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:34:3
				assign ysyx_23060203.NPC_CPU.inst_if.ready = ysyx_23060203.NPC_CPU.id_if.ready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:35:3
				assign ysyx_23060203.NPC_CPU.id_if.valid = ysyx_23060203.NPC_CPU.inst_if.valid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:38:3
				assign opcode = inst[6:2];
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:39:3
				assign funct = inst[14:12];
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:42:3
				wire [4:0] rs1;
				wire [4:0] rs2;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:44:3
				assign rd = inst[11:7];
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:45:3
				assign rs1 = inst[19:15];
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:46:3
				assign rs2 = inst[24:20];
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:49:3
				assign gpr_raddr1 = rs1;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:50:3
				assign src1 = gpr_rdata1;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:51:3
				assign gpr_raddr2 = rs2;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:52:3
				assign src2 = gpr_rdata2;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:55:3
				wire [31:0] immI;
				wire [31:0] immS;
				wire [31:0] immB;
				wire [31:0] immU;
				wire [31:0] immJ;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:56:3
				assign immI = {{20 {inst[31]}}, inst[31:20]};
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:57:3
				assign immS = {{20 {inst[31]}}, inst[31:25], inst[11:7]};
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:58:3
				assign immB = {{20 {inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:59:3
				assign immU = {inst[31:12], 12'b000000000000};
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:60:3
				assign immJ = {{12 {inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:62:3
				localparam [4:0] OP_AUIPC = 5'b00101;
				localparam [4:0] OP_BRANCH = 5'b11000;
				localparam [4:0] OP_CALRI = 5'b00100;
				localparam [4:0] OP_JAL = 5'b11011;
				localparam [4:0] OP_JALR = 5'b11001;
				localparam [4:0] OP_LOAD = 5'b00000;
				localparam [4:0] OP_LUI = 5'b01101;
				localparam [4:0] OP_STORE = 5'b01000;
				localparam [4:0] OP_SYS = 5'b11100;
				always @(*)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:63:5
					case (opcode)
						OP_CALRI, OP_LOAD, OP_JALR, OP_SYS:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:64:44
							imm = immI;
						OP_STORE:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:65:44
							imm = immS;
						OP_BRANCH:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:66:44
							imm = immB;
						OP_LUI, OP_AUIPC:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:67:44
							imm = immU;
						OP_JAL:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:68:44
							imm = immJ;
						default:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:69:44
							imm = 32'b00000000000000000000000000000000;
					endcase
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:74:3
				wire [31:0] zimm = {27'b000000000000000000000000000, inst[19:15]};
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:76:3
				localparam [11:0] CSR_MEPC = 12'h341;
				localparam [11:0] CSR_MTVEC = 12'h305;
				assign csr_raddr = (|funct ? inst[31:20] : (inst[31:20] == 12'b000000000000 ? CSR_MTVEC : CSR_MEPC));
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:77:3
				assign csr = csr_rdata;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:81:3
				reg [31:0] csr_alu_a;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:82:3
				localparam [2:0] CSRF_RW = 3'b001;
				localparam [2:0] CSRF_RWI = 3'b101;
				always @(*)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:83:5
					case (funct)
						3'b000:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:84:27
							csr_alu_a = pc;
						CSRF_RW, CSRF_RWI:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:85:27
							csr_alu_a = 32'b00000000000000000000000000000000;
						default:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:86:27
							csr_alu_a = csr;
					endcase
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:90:3
				localparam [4:0] OP_CALRR = 5'b01100;
				always @(*)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:91:5
					case (opcode)
						OP_LOAD, OP_STORE, OP_CALRI, OP_CALRR, OP_BRANCH:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:93:38
							alu_a = src1;
						OP_AUIPC, OP_JAL, OP_JALR:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:94:38
							alu_a = pc;
						OP_SYS:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:95:38
							alu_a = csr_alu_a;
						default:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:97:38
							alu_a = 32'b00000000000000000000000000000000;
					endcase
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:101:3
				always @(*)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:102:5
					case (opcode)
						OP_CALRR, OP_BRANCH:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:103:36
							alu_b = src2;
						OP_LUI, OP_AUIPC, OP_LOAD, OP_STORE, OP_CALRI:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:105:36
							alu_b = imm;
						OP_SYS:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:106:36
							alu_b = (funct[2] ? zimm : src1);
						default:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:108:36
							alu_b = 32'd4;
					endcase
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:112:3
				reg [2:0] branch_alu_funct;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:113:3
				localparam [2:0] ALU_LTS = 3'b010;
				localparam [2:0] ALU_LTU = 3'b011;
				localparam [2:0] ALU_XOR = 3'b100;
				localparam [2:0] BR_BGE = 3'b101;
				localparam [2:0] BR_BGEU = 3'b111;
				localparam [2:0] BR_BLT = 3'b100;
				localparam [2:0] BR_BLTU = 3'b110;
				always @(*)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:114:5
					case (funct)
						BR_BLT, BR_BGE:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:115:26
							branch_alu_funct = ALU_LTS;
						BR_BLTU, BR_BGEU:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:116:26
							branch_alu_funct = ALU_LTU;
						default:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:118:26
							branch_alu_funct = ALU_XOR;
					endcase
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:122:3
				reg [2:0] csr_alu_funct;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:123:3
				localparam [2:0] ALU_AND = 3'b111;
				localparam [2:0] ALU_OR = 3'b110;
				localparam [2:0] CSRF_RC = 3'b011;
				localparam [2:0] CSRF_RCI = 3'b111;
				localparam [2:0] CSRF_RS = 3'b010;
				localparam [2:0] CSRF_RSI = 3'b110;
				always @(*)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:124:5
					case (funct)
						CSRF_RS, CSRF_RSI:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:125:26
							csr_alu_funct = ALU_OR;
						CSRF_RC, CSRF_RCI:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:126:26
							csr_alu_funct = ALU_AND;
						default:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:129:26
							csr_alu_funct = ALU_XOR;
					endcase
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:133:3
				localparam [2:0] ALU_ADD = 3'b000;
				always @(*)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:134:5
					case (opcode)
						OP_CALRI, OP_CALRR:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:135:28
							alu_funct = funct;
						OP_BRANCH:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:136:28
							alu_funct = branch_alu_funct;
						OP_SYS:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:137:28
							alu_funct = csr_alu_funct;
						default:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:138:28
							alu_funct = ALU_ADD;
					endcase
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:143:3
				wire funcs = inst[30];
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:145:3
				localparam [2:0] ALU_SHR = 3'b101;
				wire funcs_en = (opcode == OP_CALRR) | ((opcode == OP_CALRI) & (funct == ALU_SHR));
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:147:3
				wire funcs_csr = ((opcode == OP_SYS) & funct[1]) & funct[0];
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_IDU.sv:149:3
				assign alu_funcs = (funcs & funcs_en) | funcs_csr;
			end
			assign IDU.pc = pc;
			assign IDU.inst = inst;
			assign gpr_raddr1 = IDU.gpr_raddr1;
			assign IDU.gpr_rdata1 = gpr_rdata1;
			assign gpr_raddr2 = IDU.gpr_raddr2;
			assign IDU.gpr_rdata2 = gpr_rdata2;
			assign csr_raddr = IDU.csr_raddr;
			assign IDU.csr_rdata = csr_rdata;
			assign alu_a = IDU.alu_a;
			assign alu_b = IDU.alu_b;
			assign alu_funct = IDU.alu_funct;
			assign alu_funcs = IDU.alu_funcs;
			assign opcode = IDU.opcode;
			assign funct = IDU.funct;
			assign rd = IDU.rd;
			assign src1 = IDU.src1;
			assign src2 = IDU.src2;
			assign imm = IDU.imm;
			assign csr = IDU.csr;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:77:3
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:79:3
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:80:3
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:81:3
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:82:3
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:84:3
			// expanded interface instance: mem_rreq
			if (1) begin : mem_rreq
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:2:3
				reg valid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:3:3
				wire ready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:5:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:10:3
			end
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:85:3
			// expanded interface instance: mem_rres
			if (1) begin : mem_rres
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:2:3
				wire valid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:3:3
				reg ready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:5:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:10:3
			end
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:86:3
			wire [2:0] mem_rfunc;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:87:3
			wire [31:0] mem_raddr;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:88:3
			// expanded interface instance: mem_wreq
			if (1) begin : mem_wreq
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:2:3
				reg valid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:3:3
				wire ready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:5:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:10:3
			end
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:89:3
			// expanded interface instance: mem_wres
			if (1) begin : mem_wres
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:2:3
				wire valid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:3:3
				reg ready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:5:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/decouple.sv:10:3
			end
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:90:3
			wire [2:0] mem_wfunc;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:91:3
			wire [31:0] mem_waddr;
			wire [31:0] mem_wdata;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:92:3
			wire [31:0] mem_rdata;
			// expanded module instance: EXU
			if (1) begin : EXU
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:2:3
				wire rstn;
				wire clk;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:5:3
				wire [31:0] pc;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:6:3
				wire [4:0] opcode;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:7:3
				wire [2:0] funct;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:8:3
				wire [4:0] rd;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:9:3
				wire [31:0] src1;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:10:3
				wire [31:0] src2;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:11:3
				wire [31:0] imm;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:12:3
				wire [31:0] csr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:13:3
				wire [31:0] alu_a;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:14:3
				wire [31:0] alu_b;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:15:3
				wire [2:0] alu_funct;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:16:3
				wire alu_funcs;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:17:3
				// removed modport instance id_in
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:20:3
				wire [31:0] npc;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:23:3
				reg gpr_wen;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:24:3
				reg [4:0] gpr_waddr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:25:3
				reg [31:0] gpr_wdata;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:28:3
				reg csr_wen1;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:29:3
				reg [11:0] csr_waddr1;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:30:3
				reg [31:0] csr_wdata1;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:31:3
				reg csr_wen2;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:32:3
				reg [11:0] csr_waddr2;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:33:3
				reg [31:0] csr_wdata2;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:37:3
				reg [31:0] mem_raddr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:38:3
				reg [2:0] mem_rfunc;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:39:3
				// removed modport instance mem_rreq
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:41:3
				wire [31:0] mem_rdata;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:42:3
				// removed modport instance mem_rres
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:44:3
				reg [2:0] mem_wfunc;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:45:3
				reg [31:0] mem_waddr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:46:3
				reg [31:0] mem_wdata;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:47:3
				// removed modport instance mem_wreq
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:48:3
				// removed modport instance mem_wres
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:51:3
				wire [31:0] alu_val;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:52:3
				ysyx_23060203_ALU ALU(
					.alu_a(alu_a),
					.alu_b(alu_b),
					.funct(alu_funct),
					.funcs(alu_funcs),
					.val(alu_val)
				);
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:61:3
				reg id_gpr_wen;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:62:3
				reg [31:0] id_gpr_wdata;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:63:3
				localparam [4:0] OP_AUIPC = 5'b00101;
				localparam [4:0] OP_BRANCH = 5'b11000;
				localparam [4:0] OP_CALRI = 5'b00100;
				localparam [4:0] OP_CALRR = 5'b01100;
				localparam [4:0] OP_JAL = 5'b11011;
				localparam [4:0] OP_JALR = 5'b11001;
				localparam [4:0] OP_LOAD = 5'b00000;
				localparam [4:0] OP_LUI = 5'b01101;
				localparam [4:0] OP_STORE = 5'b01000;
				localparam [4:0] OP_SYS = 5'b11100;
				always @(*)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:64:5
					case (opcode)
						OP_LUI, OP_AUIPC, OP_JAL, OP_JALR, OP_LOAD, OP_CALRI, OP_CALRR:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:66:44
							id_gpr_wen = 1'b1;
						OP_SYS:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:67:44
							id_gpr_wen = |funct;
						OP_BRANCH, OP_STORE:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:68:44
							id_gpr_wen = 1'b0;
						default:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:69:44
							id_gpr_wen = 1'b0;
					endcase
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:72:3
				always @(*)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:73:5
					case (opcode)
						OP_LUI, OP_AUIPC, OP_JAL, OP_JALR, OP_CALRI, OP_CALRR:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:75:44
							id_gpr_wdata = alu_val;
						OP_SYS:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:76:44
							id_gpr_wdata = csr;
						default:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:77:44
							id_gpr_wdata = alu_val;
					endcase
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:82:3
				wire [11:0] csr_addr = imm[11:0];
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:83:3
				wire ecall = (opcode == OP_SYS) & (csr_addr == 12'b000000000000);
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:85:3
				wire id_csr_wen1 = (opcode == OP_SYS) & (|funct | (csr_addr == 12'b000000000000));
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:86:3
				localparam [11:0] CSR_MEPC = 12'h341;
				wire [11:0] id_csr_waddr1 = (|funct ? csr_addr : CSR_MEPC);
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:87:3
				wire [31:0] id_csr_wdata1 = alu_val;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:89:3
				wire id_csr_wen2 = ecall;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:90:3
				localparam [11:0] CSR_MCAUSE = 12'h342;
				wire [11:0] id_csr_waddr2 = CSR_MCAUSE;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:91:3
				wire [31:0] id_csr_wdata2 = 32'd11;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:94:3
				reg [31:0] pc_inc;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:95:3
				wire pc_ovrd;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:96:3
				wire [31:0] pc_ovrd_addr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:97:3
				wire csr_jump = (opcode == OP_SYS) & (funct == 3'b000);
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:98:3
				assign pc_ovrd = (opcode == OP_JALR) | csr_jump;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:99:3
				assign pc_ovrd_addr = (csr_jump ? csr : src1);
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:100:3
				wire alu_zf_n = |alu_val;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:101:3
				reg br_en;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:102:3
				localparam [2:0] BR_BEQ = 3'b000;
				localparam [2:0] BR_BGE = 3'b101;
				localparam [2:0] BR_BGEU = 3'b111;
				localparam [2:0] BR_BLT = 3'b100;
				localparam [2:0] BR_BLTU = 3'b110;
				localparam [2:0] BR_BNE = 3'b001;
				always @(*)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:103:5
					case (funct)
						BR_BEQ:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:104:25
							br_en = ~alu_zf_n;
						BR_BNE:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:105:25
							br_en = alu_zf_n;
						BR_BLT, BR_BLTU:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:106:25
							br_en = alu_val[0];
						BR_BGE, BR_BGEU:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:107:25
							br_en = ~alu_val[0];
						default:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:108:25
							br_en = 0;
					endcase
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:111:3
				always @(*)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:112:5
					case (opcode)
						OP_JAL, OP_JALR:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:113:25
							pc_inc = imm;
						OP_BRANCH:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:114:25
							pc_inc = (br_en ? imm : 4);
						OP_SYS:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:115:25
							pc_inc = (csr_jump ? 0 : 4);
						default:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:116:25
							pc_inc = 4;
					endcase
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:119:3
				wire [31:0] npc_base = (pc_ovrd ? pc_ovrd_addr : pc);
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:120:3
				wire [31:0] npc_orig = npc_base + pc_inc;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:121:3
				assign npc = {npc_orig[31:1], 1'b0};
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:124:3
				reg load_flag;
				reg mem_res_flag;
				reg store_flag;
				always @(posedge clk)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:125:5
					if (~rstn) begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:126:7
						ysyx_23060203.NPC_CPU.id_if.ready <= 1;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:128:7
						ysyx_23060203.NPC_CPU.mem_rreq.valid <= 0;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:129:7
						ysyx_23060203.NPC_CPU.mem_rres.ready <= 1;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:130:7
						ysyx_23060203.NPC_CPU.mem_wreq.valid <= 0;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:131:7
						ysyx_23060203.NPC_CPU.mem_wres.ready <= 1;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:133:7
						load_flag <= 0;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:134:7
						store_flag <= 0;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:135:7
						mem_res_flag <= 0;
					end
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:140:3
				reg [31:0] alu_val_reg;
				reg [31:0] src2_reg;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:141:3
				reg [2:0] funct_reg;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:142:3
				reg [4:0] opcode_reg;
				reg [4:0] rd_reg;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:144:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:146:3
				wire mem_r_res_hs = ysyx_23060203.NPC_CPU.mem_rres.valid & ysyx_23060203.NPC_CPU.mem_rres.ready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:147:3
				wire mem_w_res_hs = ysyx_23060203.NPC_CPU.mem_wres.valid & ysyx_23060203.NPC_CPU.mem_wres.ready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:148:3
				wire id_ls = (opcode == OP_LOAD) | (opcode == OP_STORE);
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:150:3
				always @(posedge clk)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:150:31
					if (rstn) begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:151:5
						if (ysyx_23060203.NPC_CPU.id_if.ready & ysyx_23060203.NPC_CPU.id_if.valid) begin
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:152:7
							alu_val_reg <= alu_val;
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:153:7
							src2_reg <= src2;
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:154:7
							funct_reg <= funct;
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:155:7
							opcode_reg <= opcode;
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:156:7
							rd_reg <= rd;
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:158:7
							if (id_gpr_wen & (opcode != OP_LOAD)) begin
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:159:9
								gpr_wen <= 1;
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:160:9
								gpr_waddr <= rd;
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:161:9
								gpr_wdata <= id_gpr_wdata;
							end
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:164:7
							csr_wen1 <= id_csr_wen1;
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:165:7
							csr_waddr1 <= id_csr_waddr1;
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:166:7
							csr_wdata1 <= id_csr_wdata1;
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:167:7
							csr_wen2 <= id_csr_wen2;
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:168:7
							csr_waddr2 <= id_csr_waddr2;
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:169:7
							csr_wdata2 <= id_csr_wdata2;
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:171:7
							ysyx_23060203.NPC_CPU.id_if.ready <= ~id_ls;
						end
						if (~ysyx_23060203.NPC_CPU.id_if.ready | ysyx_23060203.NPC_CPU.id_if.valid) begin
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:176:7
							case ((ysyx_23060203.NPC_CPU.id_if.valid ? opcode : opcode_reg))
								OP_LOAD:
									if (~ysyx_23060203.NPC_CPU.mem_rreq.valid & ~load_flag) begin
										// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:179:13
										ysyx_23060203.NPC_CPU.mem_rreq.valid <= 1;
										// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:180:13
										mem_raddr <= alu_val;
										// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:181:13
										mem_rfunc <= funct;
										// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:182:13
										load_flag <= 1;
									end
								OP_STORE:
									if (~ysyx_23060203.NPC_CPU.mem_wreq.valid & ~store_flag) begin
										// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:186:13
										ysyx_23060203.NPC_CPU.mem_wreq.valid <= 1;
										// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:187:13
										mem_wfunc <= (ysyx_23060203.NPC_CPU.id_if.valid ? funct : funct_reg);
										// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:188:13
										mem_waddr <= (ysyx_23060203.NPC_CPU.id_if.valid ? alu_val : alu_val_reg);
										// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:189:13
										mem_wdata <= (ysyx_23060203.NPC_CPU.id_if.valid ? src2 : src2_reg);
										// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:190:13
										store_flag <= 1;
									end
								default:
									;
							endcase
							if (ysyx_23060203.NPC_CPU.mem_rreq.valid & ysyx_23060203.NPC_CPU.mem_rreq.ready)
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:197:9
								ysyx_23060203.NPC_CPU.mem_rreq.valid <= 0;
							if (ysyx_23060203.NPC_CPU.mem_wreq.valid & ysyx_23060203.NPC_CPU.mem_wreq.ready)
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:201:9
								ysyx_23060203.NPC_CPU.mem_wreq.valid <= 0;
							if (mem_r_res_hs) begin
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:206:9
								gpr_wen <= 1;
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:207:9
								gpr_waddr <= rd_reg;
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:208:9
								gpr_wdata <= mem_rdata;
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:209:9
								ysyx_23060203.NPC_CPU.id_if.ready <= 1;
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:210:9
								load_flag <= 0;
							end
							if (mem_w_res_hs) begin
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:213:9
								ysyx_23060203.NPC_CPU.id_if.ready <= 1;
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:214:9
								store_flag <= 0;
							end
						end
						if (gpr_wen)
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:221:7
							gpr_wen <= 0;
						if (csr_wen1)
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:225:7
							csr_wen1 <= 0;
						if (csr_wen2)
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_EXU.sv:228:7
							csr_wen2 <= 0;
					end
			end
			assign EXU.rstn = rstn;
			assign EXU.clk = clk;
			assign EXU.pc = pc;
			assign EXU.opcode = opcode;
			assign EXU.funct = funct;
			assign EXU.rd = rd;
			assign EXU.src1 = src1;
			assign EXU.src2 = src2;
			assign EXU.imm = imm;
			assign EXU.csr = csr;
			assign EXU.alu_a = alu_a;
			assign EXU.alu_b = alu_b;
			assign EXU.alu_funct = alu_funct;
			assign EXU.alu_funcs = alu_funcs;
			assign npc = EXU.npc;
			assign gpr_wen = EXU.gpr_wen;
			assign gpr_waddr = EXU.gpr_waddr;
			assign gpr_wdata = EXU.gpr_wdata;
			assign csr_wen1 = EXU.csr_wen1;
			assign csr_wen2 = EXU.csr_wen2;
			assign csr_waddr1 = EXU.csr_waddr1;
			assign csr_waddr2 = EXU.csr_waddr2;
			assign csr_wdata1 = EXU.csr_wdata1;
			assign csr_wdata2 = EXU.csr_wdata2;
			assign mem_raddr = EXU.mem_raddr;
			assign mem_rfunc = EXU.mem_rfunc;
			assign EXU.mem_rdata = mem_rdata;
			assign mem_wfunc = EXU.mem_wfunc;
			assign mem_waddr = EXU.mem_waddr;
			assign mem_wdata = EXU.mem_wdata;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:120:3
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:121:3
			// expanded interface instance: lsu_mem_r
			if (1) begin : lsu_mem_r
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:3:3
				wire awvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:4:3
				wire awready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:5:3
				wire [31:0] awaddr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:6:3
				wire [3:0] awid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:7:3
				wire [7:0] awlen;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:8:3
				wire [2:0] awsize;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:9:3
				wire [1:0] awburst;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:10:3
				wire wready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:11:3
				wire wvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:12:3
				wire [63:0] wdata;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:13:3
				wire [7:0] wstrb;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:14:3
				wire wlast;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:15:3
				wire bready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:16:3
				wire bvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:17:3
				wire [1:0] bresp;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:18:3
				wire [3:0] bid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:20:3
				wire arready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:21:3
				wire arvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:22:3
				wire [31:0] araddr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:23:3
				wire [3:0] arid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:24:3
				wire [7:0] arlen;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:25:3
				reg [2:0] arsize;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:26:3
				wire [1:0] arburst;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:27:3
				wire rready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:28:3
				wire rvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:29:3
				wire [1:0] rresp;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:30:3
				wire [63:0] rdata;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:31:3
				wire rlast;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:32:3
				wire [3:0] rid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:34:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:68:3
			end
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:122:3
			// expanded module instance: LSU
			if (1) begin : LSU
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:2:3
				wire rstn;
				wire clk;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:5:3
				wire [31:0] raddr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:6:3
				wire [2:0] rfunc;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:7:3
				// removed modport instance rreq
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:9:3
				wire [31:0] rdata;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:10:3
				// removed modport instance rres
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:12:3
				wire [2:0] wfunc;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:13:3
				wire [31:0] waddr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:14:3
				wire [31:0] wdata;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:15:3
				// removed modport instance wreq
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:16:3
				// removed modport instance wres
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:19:3
				// removed modport instance ram_r
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:20:3
				// removed modport instance ram_w
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:24:3
				reg [2:0] raddr_align_reg;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:25:3
				reg [2:0] rfunc_reg;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:28:3
				wire [63:0] ram_r_rdata_shifted = ysyx_23060203.NPC_CPU.lsu_mem_r.rdata >> {raddr_align_reg, 3'b000};
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:30:3
				reg [31:0] ram_r_rdata_word;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:31:3
				localparam [2:0] LD_BS = 3'b000;
				localparam [2:0] LD_BU = 3'b100;
				localparam [2:0] LD_HS = 3'b001;
				localparam [2:0] LD_HU = 3'b101;
				always @(*)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:32:5
					case (rfunc_reg)
						LD_BS:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:33:14
							ram_r_rdata_word = {{24 {ram_r_rdata_shifted[7]}}, ram_r_rdata_shifted[7:0]};
						LD_BU:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:34:14
							ram_r_rdata_word = {24'b000000000000000000000000, ram_r_rdata_shifted[7:0]};
						LD_HS:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:35:14
							ram_r_rdata_word = {{16 {ram_r_rdata_shifted[15]}}, ram_r_rdata_shifted[15:0]};
						LD_HU:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:36:14
							ram_r_rdata_word = {16'b0000000000000000, ram_r_rdata_shifted[15:0]};
						default:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:38:16
							ram_r_rdata_word = ram_r_rdata_shifted[31:0];
					endcase
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:43:3
				assign ysyx_23060203.NPC_CPU.lsu_mem_r.arvalid = ysyx_23060203.NPC_CPU.mem_rreq.valid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:44:3
				assign ysyx_23060203.NPC_CPU.lsu_mem_r.araddr = raddr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:45:3
				always @(*)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:46:5
					case (rfunc)
						LD_BS, LD_BU:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:47:21
							ysyx_23060203.NPC_CPU.lsu_mem_r.arsize = 3'b000;
						LD_HS, LD_HU:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:48:21
							ysyx_23060203.NPC_CPU.lsu_mem_r.arsize = 3'b001;
						default:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:49:16
							ysyx_23060203.NPC_CPU.lsu_mem_r.arsize = 3'b010;
					endcase
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:53:3
				assign ysyx_23060203.NPC_CPU.mem_rreq.ready = ysyx_23060203.NPC_CPU.lsu_mem_r.arready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:54:3
				always @(posedge clk)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:55:5
					if (ysyx_23060203.NPC_CPU.mem_rreq.valid & ysyx_23060203.NPC_CPU.mem_rreq.ready) begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:56:7
						raddr_align_reg <= raddr[2:0];
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:57:7
						rfunc_reg <= rfunc;
					end
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:61:3
				assign rdata = ram_r_rdata_word;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:62:3
				assign ysyx_23060203.NPC_CPU.mem_rres.valid = ysyx_23060203.NPC_CPU.lsu_mem_r.rvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:63:3
				assign ysyx_23060203.NPC_CPU.lsu_mem_r.rready = ysyx_23060203.NPC_CPU.mem_rres.ready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:65:3
				always @(posedge clk)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:66:5
					if (ysyx_23060203.NPC_CPU.lsu_mem_r.rvalid & ysyx_23060203.NPC_CPU.lsu_mem_r.rready)
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:67:7
						event_mem_read(raddr, {29'b00000000000000000000000000000, ysyx_23060203.NPC_CPU.lsu_mem_r.arsize}, rdata);
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:72:3
				assign ysyx_23060203.io_master.awid = 0;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:73:3
				assign ysyx_23060203.io_master.awlen = 0;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:74:3
				assign ysyx_23060203.io_master.awburst = 0;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:75:3
				assign ysyx_23060203.io_master.wlast = 1;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:76:3
				localparam [2:0] ST_H = 3'b001;
				localparam [2:0] ST_W = 3'b010;
				always @(*)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:77:5
					case (wfunc)
						ST_H:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:79:13
							ysyx_23060203.io_master.awsize = 3'b001;
						ST_W:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:80:13
							ysyx_23060203.io_master.awsize = 3'b010;
						default:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:81:16
							ysyx_23060203.io_master.awsize = 3'b000;
					endcase
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:85:3
				wire [63:0] wdata_aligned = {32'b00000000000000000000000000000000, wdata} << {waddr[2:0], 3'b000};
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:86:3
				reg [7:0] wmask;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:87:3
				localparam [2:0] ST_B = 3'b000;
				always @(*)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:88:5
					case (wfunc)
						ST_B:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:89:13
							wmask = 8'b00000001;
						ST_H:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:90:13
							wmask = 8'b00000011;
						default:
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:92:16
							wmask = 8'b00001111;
					endcase
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:95:3
				wire [7:0] wmask_aligned = wmask << waddr[2:0];
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:97:3
				reg waddr_flag;
				reg wdata_flag;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:98:3
				always @(posedge clk) begin
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:99:5
					if (~rstn) begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:100:7
						waddr_flag <= 1;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:101:7
						wdata_flag <= 1;
					end
					if (ysyx_23060203.io_master.awvalid & ysyx_23060203.io_master.awready) begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:105:7
						waddr_flag <= 0;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:106:7
						event_mem_write(waddr, {29'b00000000000000000000000000000, ysyx_23060203.io_master.awsize}, wdata);
					end
					if (ysyx_23060203.io_master.wvalid & ysyx_23060203.io_master.wready)
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:109:7
						wdata_flag <= 0;
					if (ysyx_23060203.io_master.bvalid & ysyx_23060203.io_master.bready) begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:112:7
						waddr_flag <= 1;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:113:7
						wdata_flag <= 1;
					end
				end
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:116:3
				assign ysyx_23060203.io_master.awaddr = waddr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:117:3
				assign ysyx_23060203.io_master.awvalid = ysyx_23060203.NPC_CPU.mem_wreq.valid & waddr_flag;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:118:3
				assign ysyx_23060203.io_master.wdata = wdata_aligned;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:119:3
				assign ysyx_23060203.io_master.wstrb = wmask_aligned;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:120:3
				assign ysyx_23060203.io_master.wvalid = ysyx_23060203.NPC_CPU.mem_wreq.valid & wdata_flag;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:121:3
				assign ysyx_23060203.NPC_CPU.mem_wreq.ready = (ysyx_23060203.io_master.awready | ~waddr_flag) & (ysyx_23060203.io_master.wready | ~wdata_flag);
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:123:3
				assign ysyx_23060203.NPC_CPU.mem_wres.valid = ysyx_23060203.io_master.bvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_LSU.sv:124:3
				assign ysyx_23060203.io_master.bready = ysyx_23060203.NPC_CPU.mem_wres.ready;
			end
			assign LSU.rstn = rstn;
			assign LSU.clk = clk;
			assign LSU.raddr = mem_raddr;
			assign LSU.rfunc = mem_rfunc;
			assign mem_rdata = LSU.rdata;
			assign LSU.wfunc = mem_wfunc;
			assign LSU.waddr = mem_waddr;
			assign LSU.wdata = mem_wdata;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:136:3
			// expanded interface instance: mem_r
			if (1) begin : mem_r
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:3:3
				wire awvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:4:3
				wire awready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:5:3
				wire [31:0] awaddr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:6:3
				wire [3:0] awid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:7:3
				wire [7:0] awlen;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:8:3
				wire [2:0] awsize;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:9:3
				wire [1:0] awburst;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:10:3
				wire wready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:11:3
				wire wvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:12:3
				wire [63:0] wdata;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:13:3
				wire [7:0] wstrb;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:14:3
				wire wlast;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:15:3
				wire bready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:16:3
				wire bvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:17:3
				wire [1:0] bresp;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:18:3
				wire [3:0] bid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:20:3
				reg arready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:21:3
				wire arvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:22:3
				wire [31:0] araddr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:23:3
				wire [3:0] arid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:24:3
				wire [7:0] arlen;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:25:3
				wire [2:0] arsize;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:26:3
				wire [1:0] arburst;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:27:3
				wire rready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:28:3
				reg rvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:29:3
				reg [1:0] rresp;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:30:3
				reg [63:0] rdata;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:31:3
				wire rlast;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:32:3
				wire [3:0] rid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:34:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:68:3
			end
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:137:3
			// expanded module instance: MemArb
			if (1) begin : MemArb
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:2:3
				wire rstn;
				wire clk;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:4:3
				// removed modport instance ifu_r
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:5:3
				// removed modport instance lsu_r
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:8:3
				// removed modport instance ram_r
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:11:3
				reg lst_dev;
				reg req_ready;
				reg tmp_flag;
				always @(posedge clk)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:12:5
					if (~rstn) begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:13:7
						req_ready <= 1;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:14:7
						lst_dev <= 0;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:15:7
						tmp_flag <= 0;
					end
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:20:3
				assign ysyx_23060203.NPC_CPU.mem_r.arlen = 0;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:21:3
				assign ysyx_23060203.NPC_CPU.mem_r.arburst = 0;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:22:3
				assign ysyx_23060203.NPC_CPU.mem_r.arid = 0;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:25:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:27:3
				wire ifu_r_hs = ysyx_23060203.NPC_CPU.ifu_mem_r.arvalid & ysyx_23060203.NPC_CPU.ifu_mem_r.arready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:28:3
				wire lsu_r_hs = ysyx_23060203.NPC_CPU.lsu_mem_r.arvalid & ysyx_23060203.NPC_CPU.lsu_mem_r.arready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:30:3
				wire req_dev = (tmp_flag ? 0 : (ysyx_23060203.NPC_CPU.ifu_mem_r.arvalid & ysyx_23060203.NPC_CPU.lsu_mem_r.arvalid ? 1 : ysyx_23060203.NPC_CPU.lsu_mem_r.arvalid));
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:34:3
				assign ysyx_23060203.NPC_CPU.mem_r.arvalid = (tmp_flag ? 1 : req_ready & (req_dev ? ysyx_23060203.NPC_CPU.lsu_mem_r.arvalid : ysyx_23060203.NPC_CPU.ifu_mem_r.arvalid));
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:37:3
				reg [31:0] tmp_raddr;
				assign ysyx_23060203.NPC_CPU.mem_r.araddr = (tmp_flag ? tmp_raddr : (req_dev ? ysyx_23060203.NPC_CPU.lsu_mem_r.araddr : ysyx_23060203.NPC_CPU.ifu_mem_r.araddr));
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:40:3
				reg [2:0] tmp_rsize;
				assign ysyx_23060203.NPC_CPU.mem_r.arsize = (tmp_flag ? tmp_rsize : (req_dev ? ysyx_23060203.NPC_CPU.lsu_mem_r.arsize : ysyx_23060203.NPC_CPU.ifu_mem_r.arsize));
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:44:3
				assign ysyx_23060203.NPC_CPU.ifu_mem_r.arready = req_ready & ysyx_23060203.NPC_CPU.mem_r.arready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:45:3
				assign ysyx_23060203.NPC_CPU.lsu_mem_r.arready = req_ready & ysyx_23060203.NPC_CPU.mem_r.arready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:47:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:48:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:49:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:50:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:51:3
				always @(posedge clk)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:51:31
					if (rstn) begin
						begin
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:52:5
							if (ysyx_23060203.NPC_CPU.mem_r.arvalid & ysyx_23060203.NPC_CPU.mem_r.arready) begin
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:53:7
								lst_dev <= req_dev;
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:54:7
								req_ready <= 0;
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:55:7
								if (ifu_r_hs & lsu_r_hs) begin
									// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:56:9
									tmp_flag <= 1;
									// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:57:9
									tmp_raddr <= ysyx_23060203.NPC_CPU.ifu_mem_r.araddr;
									// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:58:9
									tmp_rsize <= ysyx_23060203.NPC_CPU.ifu_mem_r.arsize;
									// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:59:9
									req_ready <= 0;
								end
								else if (tmp_flag)
									// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:61:9
									tmp_flag <= 0;
							end
						end
					end
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:66:3
				wire res_dev = lst_dev;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:68:3
				assign ysyx_23060203.NPC_CPU.ifu_mem_r.rdata = ysyx_23060203.NPC_CPU.mem_r.rdata;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:69:3
				assign ysyx_23060203.NPC_CPU.lsu_mem_r.rdata = ysyx_23060203.NPC_CPU.mem_r.rdata;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:70:3
				assign ysyx_23060203.NPC_CPU.ifu_mem_r.rresp = ysyx_23060203.NPC_CPU.mem_r.rresp;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:71:3
				assign ysyx_23060203.NPC_CPU.lsu_mem_r.rresp = ysyx_23060203.NPC_CPU.mem_r.rresp;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:72:3
				assign ysyx_23060203.NPC_CPU.ifu_mem_r.rvalid = (~res_dev ? ysyx_23060203.NPC_CPU.mem_r.rvalid : 0);
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:73:3
				assign ysyx_23060203.NPC_CPU.lsu_mem_r.rvalid = (res_dev ? ysyx_23060203.NPC_CPU.mem_r.rvalid : 0);
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:74:3
				assign ysyx_23060203.NPC_CPU.mem_r.rready = (res_dev ? ysyx_23060203.NPC_CPU.lsu_mem_r.rready : ysyx_23060203.NPC_CPU.ifu_mem_r.rready);
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:76:3
				always @(posedge clk)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:76:31
					if (rstn) begin
						begin
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:77:5
							if (ysyx_23060203.NPC_CPU.mem_r.rvalid & ysyx_23060203.NPC_CPU.mem_r.rready)
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_MemArb.sv:78:7
								req_ready <= ~tmp_flag;
						end
					end
			end
			assign MemArb.rstn = rstn;
			assign MemArb.clk = clk;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:143:3
			// expanded interface instance: clint_r
			if (1) begin : clint_r
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:3:3
				wire awvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:4:3
				wire awready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:5:3
				wire [31:0] awaddr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:6:3
				wire [3:0] awid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:7:3
				wire [7:0] awlen;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:8:3
				wire [2:0] awsize;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:9:3
				wire [1:0] awburst;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:10:3
				wire wready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:11:3
				wire wvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:12:3
				wire [63:0] wdata;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:13:3
				wire [7:0] wstrb;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:14:3
				wire wlast;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:15:3
				wire bready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:16:3
				wire bvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:17:3
				wire [1:0] bresp;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:18:3
				wire [3:0] bid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:20:3
				wire arready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:21:3
				reg arvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:22:3
				wire [31:0] araddr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:23:3
				wire [3:0] arid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:24:3
				wire [7:0] arlen;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:25:3
				wire [2:0] arsize;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:26:3
				wire [1:0] arburst;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:27:3
				wire rready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:28:3
				wire rvalid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:29:3
				wire [1:0] rresp;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:30:3
				wire [63:0] rdata;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:31:3
				wire rlast;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:32:3
				wire [3:0] rid;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:34:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/interface/axi.sv:68:3
			end
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:144:3
			// expanded module instance: Xbar
			if (1) begin : Xbar
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:2:3
				wire rstn;
				wire clk;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:4:3
				// removed modport instance read
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:5:3
				// removed modport instance soc_r
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:6:3
				// removed modport instance clint_r
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:9:3
				reg rreq_ready;
				reg rres_clint;
				reg rres_soc;
				always @(posedge clk)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:9:31
					if (~rstn) begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:10:5
						rreq_ready <= 1;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:11:5
						rres_soc <= 0;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:12:5
						rres_clint <= 0;
					end
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:18:3
				assign ysyx_23060203.NPC_CPU.clint_r.arlen = 0;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:19:3
				assign ysyx_23060203.NPC_CPU.clint_r.arburst = 0;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:20:3
				assign ysyx_23060203.NPC_CPU.clint_r.arid = 0;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:21:3
				assign ysyx_23060203.io_master.arlen = 0;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:22:3
				assign ysyx_23060203.io_master.arburst = 0;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:23:3
				assign ysyx_23060203.io_master.arid = 0;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:26:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:27:3
				wire rreq_clint = ysyx_23060203.NPC_CPU.mem_r.araddr[31:4] == 28'ha000004;
				wire rreq_soc = ~rreq_clint;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:28:3
				assign ysyx_23060203.io_master.araddr = ysyx_23060203.NPC_CPU.mem_r.araddr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:29:3
				assign ysyx_23060203.io_master.arsize = ysyx_23060203.NPC_CPU.mem_r.arsize;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:30:3
				assign ysyx_23060203.NPC_CPU.clint_r.araddr = ysyx_23060203.NPC_CPU.mem_r.araddr;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:31:3
				assign ysyx_23060203.NPC_CPU.clint_r.arsize = ysyx_23060203.NPC_CPU.mem_r.arsize;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:36:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:39:3
				always @(*)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:40:5
					if (rreq_soc) begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:41:7
						ysyx_23060203.NPC_CPU.mem_r.arready = rreq_ready & ysyx_23060203.io_master.arready;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:42:7
						ysyx_23060203.io_master.arvalid = rreq_ready & ysyx_23060203.NPC_CPU.mem_r.arvalid;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:43:7
						ysyx_23060203.NPC_CPU.clint_r.arvalid = 0;
					end
					else if (rreq_clint) begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:45:7
						ysyx_23060203.NPC_CPU.mem_r.arready = rreq_ready & ysyx_23060203.NPC_CPU.clint_r.arready;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:46:7
						ysyx_23060203.NPC_CPU.clint_r.arvalid = rreq_ready & ysyx_23060203.NPC_CPU.mem_r.arvalid;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:47:7
						ysyx_23060203.io_master.arvalid = 0;
					end
					else begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:49:7
						ysyx_23060203.NPC_CPU.mem_r.arready = 0;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:50:7
						ysyx_23060203.io_master.arvalid = 0;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:51:7
						ysyx_23060203.NPC_CPU.clint_r.arvalid = 0;
					end
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:54:3
				always @(posedge clk)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:54:31
					if (rstn) begin
						begin
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:55:5
							if (ysyx_23060203.NPC_CPU.mem_r.arvalid & ysyx_23060203.NPC_CPU.mem_r.arready) begin
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:56:7
								rres_soc <= rreq_soc;
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:57:7
								rres_clint <= rreq_clint;
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:58:7
								rreq_ready <= 0;
							end
						end
					end
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:62:3
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:63:3
				assign ysyx_23060203.io_master.rready = rres_soc & ysyx_23060203.NPC_CPU.mem_r.rready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:64:3
				assign ysyx_23060203.NPC_CPU.clint_r.rready = rres_clint & ysyx_23060203.NPC_CPU.mem_r.rready;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:65:3
				always @(*)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:66:5
					if (rres_soc) begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:67:7
						ysyx_23060203.NPC_CPU.mem_r.rdata = ysyx_23060203.io_master.rdata;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:68:7
						ysyx_23060203.NPC_CPU.mem_r.rresp = ysyx_23060203.io_master.rresp;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:69:7
						ysyx_23060203.NPC_CPU.mem_r.rvalid = ysyx_23060203.io_master.rvalid;
					end
					else if (rres_clint) begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:71:7
						ysyx_23060203.NPC_CPU.mem_r.rdata = ysyx_23060203.NPC_CPU.clint_r.rdata;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:72:7
						ysyx_23060203.NPC_CPU.mem_r.rresp = ysyx_23060203.NPC_CPU.clint_r.rresp;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:73:7
						ysyx_23060203.NPC_CPU.mem_r.rvalid = ysyx_23060203.NPC_CPU.clint_r.rvalid;
					end
					else begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:75:7
						ysyx_23060203.NPC_CPU.mem_r.rdata = 0;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:76:7
						ysyx_23060203.NPC_CPU.mem_r.rresp = 0;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:77:7
						ysyx_23060203.NPC_CPU.mem_r.rvalid = 0;
					end
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:80:3
				always @(posedge clk)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:80:31
					if (rstn) begin
						begin
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:81:5
							if (ysyx_23060203.NPC_CPU.mem_r.rvalid & ysyx_23060203.NPC_CPU.mem_r.rready)
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_Xbar.sv:82:7
								rreq_ready <= 1;
						end
					end
			end
			assign Xbar.rstn = rstn;
			assign Xbar.clk = clk;
			// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/ysyx_23060203_CPU.sv:150:3
			// expanded module instance: clint
			if (1) begin : clint
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/ysyx_23060203_CLINT.sv:2:3
				wire rstn;
				wire clk;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/ysyx_23060203_CLINT.sv:4:3
				// removed modport instance read
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/ysyx_23060203_CLINT.sv:7:3
				reg [63:0] uptime;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/ysyx_23060203_CLINT.sv:8:3
				reg [15:0] acc;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/ysyx_23060203_CLINT.sv:9:3
				always @(posedge clk)
					// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/ysyx_23060203_CLINT.sv:10:5
					if (rstn) begin
						begin
							// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/ysyx_23060203_CLINT.sv:11:7
							if (acc == 0) begin
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/ysyx_23060203_CLINT.sv:12:9
								acc <= 0;
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/ysyx_23060203_CLINT.sv:13:9
								uptime <= uptime + 1;
							end
							else
								// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/ysyx_23060203_CLINT.sv:15:9
								acc <= acc + 1;
						end
					end
					else begin
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/ysyx_23060203_CLINT.sv:18:7
						uptime <= 0;
						// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/ysyx_23060203_CLINT.sv:19:7
						acc <= 0;
					end
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/ysyx_23060203_CLINT.sv:23:3
				assign ysyx_23060203.NPC_CPU.clint_r.arready = 1;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/ysyx_23060203_CLINT.sv:24:3
				assign ysyx_23060203.NPC_CPU.clint_r.rvalid = 1;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/ysyx_23060203_CLINT.sv:25:3
				assign ysyx_23060203.NPC_CPU.clint_r.rresp = 0;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/ysyx_23060203_CLINT.sv:26:3
				assign ysyx_23060203.NPC_CPU.clint_r.rdata = uptime;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/ysyx_23060203_CLINT.sv:27:3
				assign ysyx_23060203.NPC_CPU.clint_r.rlast = 1;
				// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/device/ysyx_23060203_CLINT.sv:28:3
				assign ysyx_23060203.NPC_CPU.clint_r.rid = 0;
			end
			assign clint.rstn = rstn;
			assign clint.clk = clk;
		end
	endgenerate
	assign NPC_CPU.clk = clock;
	assign NPC_CPU.rstn = ~reset;
endmodule
// removed module with interface ports: ysyx_23060203_IFU
// removed module with interface ports: ysyx_23060203_MemArb
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/DPIC.sv:1:1
// removed ["import \"DPI-C\"  function void halt();"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/DPIC.sv:2:1
// removed ["import \"DPI-C\"  function void inst_complete(\n\t// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/DPIC.sv:2:44\n\tinput int pc,\n\t// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/DPIC.sv:2:58\n\tinput int inst\n);"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/DPIC.sv:4:1
// removed ["import \"DPI-C\"  function void event_mem_read(\n\t// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/DPIC.sv:5:3\n\tinput int raddr,\n\t// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/DPIC.sv:6:3\n\tinput int rsize,\n\t// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/DPIC.sv:7:3\n\tinput int rdata\n);"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/DPIC.sv:9:1
// removed ["import \"DPI-C\"  function void event_mem_write(\n\t// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/DPIC.sv:10:3\n\tinput int waddr,\n\t// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/DPIC.sv:11:3\n\tinput int wsize,\n\t// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/DPIC.sv:12:3\n\tinput int wdata\n);"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/DPIC.sv:21:1
// removed ["import \"DPI-C\"  function int pmem_read(\n\t// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/DPIC.sv:21:39\n\tinput int raddr\n);"]
// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/DPIC.sv:22:1
// removed ["import \"DPI-C\"  function void pmem_write(\n\t// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/DPIC.sv:23:3\n\tinput int waddr,\n\t// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/DPIC.sv:24:3\n\tinput int wdata,\n\t// Trace: /home/cmdblock/ysyx/ysyx-workbench/npc/vsrc/DPIC.sv:25:3\n\tinput byte wmask\n);"]
// removed module with interface ports: ysyx_23060203_IDU