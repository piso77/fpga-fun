module test_attopu;

	/* Make a reset that pulses once. */
	reg reset = 0;
	initial begin
		$dumpfile("test_attopu.vcd");
		$dumpvars(0, test_attopu);

		# 4 reset = 1;
		# 4 reset = 0;
		# 92 $finish;
	end

	/* Make a regular pulsing clock. */
	reg clk = 0;
	always #1 clk = !clk;

	wire [15:0] instruction;
	wire [15:0] PC;
	wire [15:0] regOut1;
	wire [15:0] regOut2;

	processor cpu(
		.clk(clk),
		.rst(reset),
		.instruction(instruction),
		.PC(PC),
		.regOut1(regOut1),
		.regOut2(regOut2)
	);

	initial
		$monitor("At time %t: addr=0x%h instr=0x%h",
				 $time, PC, instruction);
endmodule
