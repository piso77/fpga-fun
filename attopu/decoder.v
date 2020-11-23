module decoder(
	input [15:0] instruction,
	input zFlag,										// used for branch op
	output reg [1:0] nextPCSel,			// select addr / reg PC increment for branch op
	output reg regInSource,
	output [1:0] regInSel,
	output reg regInEn,
	output [1:0] regOutSel1,
	output reg [1:0] regOutSel2,
	output reg aluOp,								// ALU op
	output reg dWE,
	output reg dAddrSel,
	output reg [15:0] addr					// address extracted from  instruction
);

	// Notice all instructions are designed in such a way that the instruction can
	// be parsed to get the registers out, even if a given instruction does not
	// use that register. The rest of the control signals will ensure nothing goes
	// wrong
	assign regInSel = instruction[13:12];
	assign regOutSel1 = instruction[11:10];

	always @(*) begin
		// Defaults
		nextPCSel = 2'b0;

		regInSource = 1'b0;
		regInEn = 1'b0;

		aluOp = 1'b0;

		dAddrSel = 1'b0;
		dWE = 1'b0;

		addr = 16'd0;

		regOutSel2 = instruction[9:8];
		// Decode the instruction and assert the relevant control signals
		case (instruction[15:14])
		// ADD
		2'b00: begin
			aluOp = 1'b1; // Make sure ALU is instructed to add
			regInSource = 1'b0; // Source the write back register data from the ALU
			regInEn = 1'b1; // Assert write back enabled
		end

		// LD
		2'b01: begin
			// LD has 2 versions, register addressing and absolute addressing, case on
			// that here
			case (instruction[0])
			// Absolute
			1'b0: begin
				dAddrSel = 1'b0; // Choose to use addr as dAddr
				dWE = 1'b0; // Read from memory
				regInSource = 1'b1; // Source the write back register data from memory
				regInEn = 1'b1; // Assert write back enabled
				addr = {5'b0, instruction[11:1]}; // Zero fill addr to get full address
			end

			// Register
			1'b1: begin
				dAddrSel = 1'b1; // Choose to use value from register file as dAddr
				dWE = 1'b0; // Read from memory
				regInSource = 1'b1; // Source the write back register data from memory
				regInEn = 1'b1; // Assert write back enabled
			end
			endcase
		end

		// ST
		2'b10: begin
			// ST has 2 versions, register addressing and absolute addressing, case on
			// that here
			case (instruction[0])
			// Absolute
			1'b0: begin
				dAddrSel = 1'b0; // Choose to use addr as dAddr
				dWE = 1'b1; // Write to memory
				regOutSel2 = regInSel;
				addr = {5'b0, instruction[11:1]}; // Zero fill addr to get full address
			end

			// Register
			1'b1: begin
				dAddrSel = 1'b1; // Choose to use value from register file as dAddr
				dWE = 1'b1; // Write to memory
			end
			endcase
		end

		// BRZ
		2'b11: begin
			// Instruction does nothing if zFlag isnt set
			if (zFlag) begin
				// BRZ has 2 versions, register addressing and relative addressing, case
				// on that here
				case (instruction[0])
				// Relative
				1'b0: begin
					nextPCSel = 2'b01; // Select to add the addr field to PC
					addr = {{5{instruction[11]}}, instruction[11:1]}; // sign extend the addr field of the instruction
				end

				// Register
				1'b1: begin
					nextPCSel = 2'b1x; // Select to use register value
				end
				endcase
			end
		end
		endcase
	end
endmodule
