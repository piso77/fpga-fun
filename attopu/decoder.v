module decoder(
	input [15:0] instruction,

	input zFlag,										// used for branch op
	output reg [1:0] nextPCSel,			// select addr / reg PC increment for branch op

	output reg regDataInSource,
	output [1:0] regInSel,
	output reg regFileWE,
	output [1:0] regOutSel1,
	output [1:0] regOutSel2,

	output reg aluOp,								// ALU op

	output reg memWE,
	output reg dAddrSel,
	output reg Muxer,
	output reg [15:0] addr					// address extracted from  instruction
);

	wire [2:0] opcode;
	wire [10:0] absaddr;
	wire signaddr;

	// Notice all instructions are designed in such a way that the instruction can
	// be parsed to get the registers out, even if a given instruction does not
	// use that register. The rest of the control signals will ensure nothing goes
	// wrong
	assign opcode = instruction[15:13];
	assign regInSel = instruction[12:11];
	assign regOutSel1 = instruction[10:9];
	assign regOutSel2 = instruction[8:7];
	assign absaddr = instruction[10:0];
	assign signaddr = instruction[10];

	always @(*) begin
		nextPCSel = 2'b0;

		regDataInSource = 1'b0;
		regFileWE = 1'b0;

		aluOp = 1'b0;

		dAddrSel = 1'b0;
		Muxer = 1'b0;
		memWE = 1'b0;

		addr = 16'd0;

		// Decode the instruction and assert the relevant control signals
		case (opcode)
			// ALU OP
			3'b000: begin
				// ADD
				aluOp = 1'b1; // Make sure ALU is instructed to add
				regFileWE = 1'b1; // Assert write back enabled
			end

			// LD
			3'b010: begin
				// Absolute
				regDataInSource = 1'b1; // Source the write back register data from memory
				regFileWE = 1'b1; // Assert write back enabled
				addr = {5'b0, absaddr}; // Zero fill addr to get full address
			end

			3'b011: begin
				// Register
				dAddrSel = 1'b1; // Choose to use value from register file as dAddr
				regDataInSource = 1'b1; // Source the write back register data from memory
				regFileWE = 1'b1; // Assert write back enabled
			end

			// ST
			3'b100: begin
				// Absolute
				memWE = 1'b1; // Write to memory
				Muxer = 1'b1;
				addr = {5'b0, absaddr}; // Zero fill addr to get full address
			end

			3'b101: begin
				// Register
				dAddrSel = 1'b1; // Choose to use value from register file as dAddr
				memWE = 1'b1; // Write to memory
			end

			// BRZ
			3'b110: begin
				if (zFlag) begin
					// relative
					nextPCSel = 2'b01; // Select to add the addr field to PC
					addr = {{5{signaddr}}, absaddr}; // sign extend the addr field of the instruction
				end
			end

			3'b111: begin
				if (zFlag) begin
					// Register
					nextPCSel = 2'b1x; // Select to use register value
				end
			end
		endcase
	end
endmodule
