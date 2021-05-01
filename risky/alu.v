module alu (
	input				[31:0]	data_in1,
	input				[31:0]	data_in2,
	input				[2:0]		alu_op,     // ALU op
	input								alu_mod,		// ALU op modifier (ADD/SUB, Shift logic/Shift arithmethic)
	output reg	[31:0]	data_out
);

	always @(*) begin
		case(alu_op)
			3'b000: data_out = alu_mod ? data_in1 - data_in2 : data_in1 + data_in2;										// ADD / SUB
			3'b001: data_out = data_in1 << data_in2[4:0];																							// SLL
			3'b010: data_out = ($signed(data_in1) < $signed(data_in2)) ? 32'b1 : 32'b0 ;							// SLT
			3'b011: data_out = (data_in1 < data_in2) ? 32'b1 : 32'b0;																	// SLTU
			3'b100: data_out = data_in1 ^ data_in2;																										// XOR
			3'b101: data_out = $signed({alu_mod ? data_in1[31] : 1'b0, data_in1}) >>> data_in2[4:0];	// SRL / SRA
			3'b110: data_out = data_in1 | data_in2;																										// OR
			3'b111: data_out = data_in1 & data_in2;																										// AND
		endcase 
	end
endmodule
