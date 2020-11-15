// Power-Up reset
// reset_n low for (2^reset_counter_size) first clocks
module pup_reset(clk, reset_n);
	input clk;
	output reset_n;

	localparam reset_counter_size = 6;
	reg [(reset_counter_size-1):0] reset_reg = 0;

	always @(posedge clk)
		reset_reg <= reset_reg + { {(reset_counter_size-1) {1'b0}}, !reset_n};

	assign reset_n = &reset_reg;
endmodule


/*
 * Generate Power-on-Reset
 */
module pon_reset(clk, reset_n);
	input clk;
	output reset_n;

	reg [9:0] por_counter = 1023;
	always @(posedge clk) begin
		if (por_counter)
			por_counter <= por_counter-1;
	end

	assign reset_n = (por_counter == 0);
endmodule
