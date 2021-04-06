module test_cpu16;

	/* Make a reset that pulses once. */
	reg reset = 0;
	initial begin
		$dumpfile("test_cpu16.vcd");
		$dumpvars(0, test_cpu16);

		# 4 reset = 1;
		# 4 reset = 0;
		# 248 $finish;
	end

	/* Make a regular pulsing clock. */	
	reg clk = 0;
	always #1 clk = !clk;

	wire [15:0] address_bus;
	reg [15:0] to_cpu;
	wire [15:0] from_cpu;
	wire write_enable;
	wire [7:0] A, B;

  reg [15:0] ram[0:65535];
  reg [15:0] rom[0:255];

	CPU16 cpu16(
		.clk(clk),
		.reset(reset),
		.address(address_bus),
		.data_in(to_cpu),
		.data_out(from_cpu),
		.write(write_enable)
	);

  always @(posedge clk)
    if (write_enable) begin
      ram[address_bus] <= from_cpu;
    end

  always @(posedge clk)
    if (address_bus[15] == 0)
      to_cpu <= ram[address_bus];
    else
      to_cpu <= rom[address_bus[7:0]];

	initial
		$readmemh("fib16.hex", rom);

	initial
		$monitor("At time %t: addr=0x%h to_cpu=0x%h A=0x%h B=0x%h",
				 $time, address_bus, to_cpu, A, B);

endmodule
