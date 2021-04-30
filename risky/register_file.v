module register_file(
	input										clk,
	input										we,					// write enable
	input						[4:0]		reg_in,			// write back register
	input						[31:0]	data_in,		// write back register data
	input						[4:0]		reg_out_1,	// register number for data_out_1
	input						[4:0]		reg_out_2,	// register number for data_out_2
	output reg			[31:0]	data_out_1,	// available one clock after reg_out_1 is set
	output reg			[31:0]	data_out_2	// available one clock after reg_out_2 is set
);

	reg [31:0] bank1 [31:0];
	reg [31:0] bank2 [31:0];

	always @(posedge clk) begin
		if (we) begin
			if(reg_in != 0) begin
				bank1[reg_in] <= data_in;
				bank2[reg_in] <= data_in;
			end
		end

		data_out_1 <= bank1[reg_out_1];
		data_out_2 <= bank2[reg_out_2];
	end
endmodule
