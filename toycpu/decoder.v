module decoder(
	input [15:0] instruction,

	input cFlag,										// used for branch op
	input zFlag,										// used for branch op
	output reg [1:0] nextPCSel,			// select addr / reg PC increment for branch op

	output reg regDataInSource,
	output reg immData,
	output [1:0] regDst,
	output reg regFileWE,
	output [1:0] regSrc1,
	output [1:0] regSrc2,

	output reg [3:0] aluOp,							// ALU op

	output reg memWE,
	output reg dAddrSel,
	output reg [15:0] instrData			// data extracted from  instruction
);

	wire [3:0] opcode;
	wire [7:0] payload;
	wire brFlagSel, brFlag;

	// Notice all instructions are designed in such a way that the instruction can
	// be parsed to get the registers out, even if a given instruction does not
	// use that register. The rest of the control signals will ensure nothing goes
	// wrong
	assign opcode = instruction[15:12];

	assign regDst = instruction[11:10];
	assign regSrc1 = instruction[9:8];
	assign regSrc2 = instruction[7:6];

	assign brFlagSel = instruction[11];
	assign brFlag = instruction[10];

	assign payload = instruction[7:0];

	always @(*) begin
		nextPCSel = 2'b0;

		regDataInSource = 1'b0;
		regFileWE = 1'b0;
		immData = 1'b0;

		dAddrSel = 1'b0;
		memWE = 1'b0;

		instrData = 16'd0;

		aluOp = 4'b0;

		// Decode the instruction and assert the relevant control signals
		case (opcode)
			// ADD OP
			4'b0000: begin
				regFileWE = 1'b1; // Assert write back enabled
				aluOp = 4'b0;
			end

			// LD IMM
			4'b1010: begin
				immData = 1'b1; // Source the write back register data from the the 'addr' field
				regFileWE = 1'b1; // Assert write back enabled
				instrData = {8'b0, payload}; // Zero fill addr to get full address
			end

			// LD IND
			4'b1011: begin
				dAddrSel = 1'b1; // Choose to use value from register file as dAddr
				regDataInSource = 1'b1; // Source the write back register data from memory
				regFileWE = 1'b1; // Assert write back enabled
			end

			// MV
			4'b1100: begin
				regFileWE = 1'b1; // Assert write back enabled
				aluOp = 4'b1111;
			end

			// ST IND
			4'b1101: begin
				dAddrSel = 1'b1; // Choose to use value from register file as dAddr
				memWE = 1'b1; // Write to memory
			end

			// BRANCH IMM
			4'b1110: begin
				if (brFlagSel == 1'b0) begin // carry
					if (brFlag == cFlag) begin
						nextPCSel = 2'b01; // Select to use the addr field as next PC
						instrData = {8'b0, payload};
					end
				end else begin // zero
					if (brFlag == zFlag) begin
						nextPCSel = 2'b01; // Select to use the addr field as next PC
						instrData = {8'b0, payload};
					end
				end
			end

			// BRANCH IND
			4'b1111: begin
				if (brFlagSel == 1'b0) begin // carry
					if (brFlag == cFlag) begin
						nextPCSel = 2'b10; // Source nextPC from rs1
					end
				end else begin // zero
					if (brFlag == zFlag) begin
						nextPCSel = 2'b10; // Source nextPC from rs1
					end
				end
			end
		endcase
	end
endmodule
