module test_cpu8;

	/* Make a reset that pulses once. */
	reg reset = 0;
	initial begin
		$dumpfile("test_cpu8.vcd");
		$dumpvars(0, test_cpu8);

		# 17 reset = 1;
		# 11 reset = 0;
		# 29 reset = 1;
		# 5  reset = 0;
		# 513 $finish;
	end

	/* Make a regular pulsing clock. */	
	reg clk = 0;
	always #1 clk = !clk;

	wire [7:0] address_bus;
	reg [7:0] to_cpu;
	wire [7:0] from_cpu;
	wire write_enable;

	reg [7:0] ram[0:127];
	reg [7:0] rom[0:127];

	CPU cpu(
		.clk(clk),
		.reset(reset),
		.address(address_bus),
		.data_in(to_cpu),
		.data_out(from_cpu),
		.write(write_enable)
	);

	always @(posedge clk)
		if (write_enable) begin
			ram[address_bus[6:0]] <= from_cpu;
		end

	always @(*)
		if (address_bus[7] == 0)
			to_cpu = ram[address_bus[6:0]];
		else
			to_cpu = rom[address_bus[6:0]];

	initial
		$readmemh("fib8.hex", rom);

	initial
		$monitor("At time %t: addr=%h, tc=%h, fc=%h, we=%h",
				 $time, address_bus, to_cpu, from_cpu, write_enable);

endmodule
