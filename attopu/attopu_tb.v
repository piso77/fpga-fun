`define assert(signal, value) \
		if (signal !== value) begin \
			$display("ASSERTION FAILED in %m: signal != value"); \
			$finish; \
		end

module test_attopu;

	/* Make a reset that pulses once. */
	reg reset = 0;
	initial begin
		$dumpfile("test_attopu.vcd");
		$dumpvars(0, test_attopu);

		#0 reset = 1;
		#1 reset = 0;
		#28 $finish;
	end

	/* Make a regular pulsing clock. */
	reg clk = 0;
	always #1 clk = !clk;

	wire [15:0] instruction;
	wire [15:0] PC;
	wire [15:0] regOut1;
	wire [15:0] regOut2;
	wire [15:0] reg0;
	wire [15:0] reg1;
	wire [15:0] reg2;
	wire [15:0] reg3;
	wire cFlag;
	wire zFlag;
	wire brFlagSel;
	wire brFlag;

	assign brFlagSel = instruction[12];
	assign brFlag = instruction[11];

	processor cpu(
		.clk(clk),
		.rst(reset),
		.instruction(instruction),
		.PC(PC),
		.regOut1(regOut1),
		.regOut2(regOut2),
		.reg0(reg0),
		.reg1(reg1),
		.reg2(reg2),
		.reg3(reg3),
		.cFlag(cFlag),
		.zFlag(zFlag)
	);

	initial begin // assertions
		#2 `assert(reg0,		16'h000a)
		#2 `assert(reg1,		16'h0002)
		#2 `assert(reg2,		16'h000c)
		#2 `assert(regOut2,	16'h000a)
		#2 `assert(reg3,		16'h000a)
		#2 `assert(reg1,		16'h000c)
		#2 `assert(reg2,		16'h000a)
	end

	initial
		$monitor("At time %t: addr=0x%h instr=0x%h regs=0x%h|0x%h|0x%h|0x%h regOut=0x%h|0x%h brFlagSel=%b brFlag=%b c/z=%b/%b rst=%b",
				 $time, PC, instruction, reg0, reg1, reg2, reg3, regOut1, regOut2, brFlagSel, brFlag, cFlag, zFlag, reset);
endmodule
