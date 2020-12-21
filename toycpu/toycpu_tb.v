`define assert(signal, value) \
		if (signal !== value) begin \
			$display("line %d: ASSERTION FAILED in %m: signal != value", `__LINE__); \
			$fatal; \
		end

module test_toycpu;

	/* Make a reset that pulses once. */
	reg reset = 0;
	initial begin
		$dumpfile("test_toycpu.vcd");
		$dumpvars(0, test_toycpu);

		#0 reset = 1;
		#2 reset = 0;
`ifdef FIBO
		#234 $finish;
`else
		#32 $finish;
`endif
	end

	/* Make a regular pulsing clock. */
	reg clk = 0;
	always #1 clk = !clk;

	wire [15:0] addr_bus;
	wire [15:0] data_in;
	wire [15:0] regDstData;
	wire [15:0] regSrcData;
	wire [15:0] reg0;
	wire [15:0] reg1;
	wire [15:0] reg2;
	wire [15:0] reg3;
	wire cFlag;
	wire zFlag;
	wire brFlagSel;
	wire brFlag;
	wire mem_we;
	wire reg_we;

	assign brFlagSel = data_in[12];
	assign brFlag = data_in[11];

	processor_top cpu(
		.clk(clk),
		.rst(reset),
		.addr_bus(addr_bus),
		.data_in(data_in),
		.mem_we(mem_we),
		.reg_we(reg_we),
		.regDstData(regDstData),
		.regSrcData(regSrcData),
		.reg0(reg0),
		.reg1(reg1),
		.reg2(reg2),
		.reg3(reg3),
		.cFlag(cFlag),
		.zFlag(zFlag)
	);

`ifdef FIBOASSERT
	initial begin // assertions
		#2	 `assert(reg0,		16'h0000)		//  LD      r0, $0
		#4	 `assert(reg0,		16'h0001)		//	ADD     r0, r0, r1
		#10	 `assert(reg0,		16'h0002)		//	ADD     r0, r0, r1
		#10	 `assert(reg0,		16'h0003)		//	ADD     r0, r0, r1
		#10	 `assert(reg0,		16'h0005)		//	ADD     r0, r0, r1
		#10	 `assert(reg0,		16'h0008)		//	ADD     r0, r0, r1
		#10	 `assert(reg0,		16'h000d)		//	ADD     r0, r0, r1
		#10	 `assert(reg0,		16'h0015)		//	ADD     r0, r0, r1
		#10	 `assert(reg0,		16'h0022)		//	ADD     r0, r0, r1
		#150 `assert(reg0,		16'hb520)		//	ADD     r0, r0, r1
		#2	 `assert(reg1,		16'h6ff1)
		#8	 `assert(reg0,		16'h2511)
	end
`elsif TESTASSERT
	initial begin // assertions
		#2 `assert(reg0,			16'h0080)		// LD  r0, $80
		#2 `assert(reg2,			16'h0080)		// MV  r2, r0
		#2 `assert(reg1,			16'h0001)		// LD  r1, $01
		#2 `assert(reg2,			16'h0081)		// ADD r2, r1
		#4 `assert(reg3,			16'h0080)		// LD  r3, $80
		#2 `assert(reg0,			16'h0081)		// LD  r0, [r3]
		#4 `assert(addr_bus,16'h0003)		// BR  nz, Loop
	end
`endif

	initial
		$monitor("%t: addr=0x%h instr=0x%h regs=0x%h|0x%h|0x%h|0x%h [D/S]Data=0x%h|0x%h [M/R]WE=%b|%b Fl=%b|%b C/Z=%b/%b rst=%b",
				 $time, addr_bus, data_in, reg0, reg1, reg2, reg3, regDstData, regSrcData, mem_we, reg_we, brFlagSel, brFlag, cFlag, zFlag, reset);
endmodule
