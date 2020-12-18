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
		#1 reset = 0;
`ifdef FIBO
		#234 $finish;
`else
		#28 $finish;
`endif
	end

	/* Make a regular pulsing clock. */
	reg clk = 0;
	always #1 clk = !clk;

	wire [15:0] instr_addr;
	wire [15:0] instr_data;
	wire [15:0] mem_addr;
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
	wire regFileWE;

	assign brFlagSel = instr_data[12];
	assign brFlag = instr_data[11];

	processor_top cpu(
		.clk(clk),
		.rst(reset),
		.instr_addr(instr_addr),
		.instr_data(instr_data),
		.mem_we(mem_we),
		.regFileWE(regFileWE),
		.mem_addr(mem_addr),
		.regDstData(regDstData),
		.regSrcData(regSrcData),
		.reg0(reg0),
		.reg1(reg1),
		.reg2(reg2),
		.reg3(reg3),
		.cFlag(cFlag),
		.zFlag(zFlag)
	);

`ifdef FIBO
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
`else
	initial begin // assertions
		#2 `assert(reg0,			16'h000a)
		#2 `assert(reg2,			16'h000a)
		#2 `assert(reg1,			16'h0002)
		#2 `assert(reg2,			16'h000c)
		#2 `assert(regSrcData,16'h000a)
		#2 `assert(reg3,			16'h000a)
		#2 `assert(reg1,			16'h000c)
		#2 `assert(reg2,			16'h000a)
	end
`endif

	initial
		$monitor("%t: addr=0x%h instr=0x%h regs=0x%h|0x%h|0x%h|0x%h mem_addr:0x%h [D/S]Data=0x%h|0x%h [M/R]WE=%b|%b Fl=%b|%b C/Z=%b/%b rst=%b",
				 $time, instr_addr, instr_data, reg0, reg1, reg2, reg3, mem_addr, regDstData, regSrcData, mem_we, regFileWE, brFlagSel, brFlag, cFlag, zFlag, reset);
endmodule
