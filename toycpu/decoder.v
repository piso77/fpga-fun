`include "header.vh"

module decoder(
	input [15:0] instruction,
	input ce,												// chip-enabe control path decoding

	output [3:0] opcode,						// used by ALU

	input cFlag,										// used for branch op
	input zFlag,										// used for branch op
	output reg [1:0] nextPCSel,			// select addr / reg PC increment for branch op

	output reg immMode,
	output reg indMode,

	output [3:0] regDst,
	output reg regFileWE,
	output [3:0] regSrc,

	output reg mem_bus_sel,
	output reg memWE,
	output reg memAddrSelDst,
	output reg memAddrSelSrc,
	output reg [15:0] instrData			// data extracted from  instruction
);

	wire [7:0] payload;
	wire brFlagSel, brFlag;

	// Notice all instructions are designed in such a way that the instruction can
	// be parsed to get the registers out, even if a given instruction does not
	// use that register. The rest of the control signals will ensure nothing goes
	// wrong
	assign opcode = instruction[15:12];

	assign regDst = instruction[11:8];
	assign regSrc = instruction[7:4];

	assign brFlagSel = instruction[9];
	assign brFlag = instruction[8];

	assign payload = instruction[7:0];

	always @(*) begin
		nextPCSel = 2'b0;

		immMode = 1'b0;
		indMode = 1'b0;

		regFileWE = 1'b0;

		memWE = 1'b0;
		memAddrSelDst = 1'b0;
		memAddrSelSrc = 1'b0;

		mem_bus_sel = 1'b0;

		instrData = 16'd0;

		if (ce) begin
			// Decode the instruction and assert the relevant control signals
			case (opcode)
				// ADD OP
				`ADD_OP: begin
					regFileWE = 1'b1; // Assert write back enabled
				end

				// LD IMM
				`LDI_OP: begin
					immMode = 1'b1;
					regFileWE = 1'b1; // Assert write back enabled
					instrData = {8'b0, payload}; // Zero fill addr to get full address
				end

				// LD IND
				`LDR_OP: begin
					mem_bus_sel = 1'b1;
					memAddrSelSrc = 1'b1; // Choose to use value from register file as dAddr
					indMode = 1'b1; // Source the write back register data from memory
					regFileWE = 1'b1; // Assert write back enabled
				end

				// MV
				`MV_OP: begin
					regFileWE = 1'b1; // Assert write back enabled
				end

				// ST IND
				`ST_OP: begin
					mem_bus_sel = 1'b1;
					memAddrSelDst = 1'b1; // Choose to use value from register file as dAddr
					memWE = 1'b1; // Write to memory
				end

				// BRANCH IMM
				`BRI_OP: begin
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
				`BRR_OP: begin
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
	end
endmodule
