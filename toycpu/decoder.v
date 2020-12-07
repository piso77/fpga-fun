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

	output [6:0] aluOp,							// ALU op

	output reg memWE,
	output reg dAddrSel,
	output reg [15:0] instrData			// data extracted from  instruction
);

	wire [2:0] opcode;
	wire [10:0] payload;
	wire msbpload;
	wire brFlagSel, brFlag;

	// Notice all instructions are designed in such a way that the instruction can
	// be parsed to get the registers out, even if a given instruction does not
	// use that register. The rest of the control signals will ensure nothing goes
	// wrong
	assign opcode = instruction[15:13];

	assign regDst = instruction[12:11];
	assign regSrc1 = instruction[10:9];
	assign regSrc2 = instruction[8:7];

	assign brFlagSel = instruction[12];
	assign brFlag = instruction[11];

	assign payload = instruction[10:0];
	assign msbpload = instruction[10];

	assign aluOp = instruction[6:0];

	always @(*) begin
		nextPCSel = 2'b0;

		regDataInSource = 1'b0;
		regFileWE = 1'b0;
		immData = 1'b0;

		dAddrSel = 1'b0;
		memWE = 1'b0;

		instrData = 16'd0;

		// Decode the instruction and assert the relevant control signals
		case (opcode)
			// ALU OP
			3'b000: begin
				regFileWE = 1'b1; // Assert write back enabled
			end

			// LD
			3'b001: begin
				// Immediate
				immData = 1'b1; // Source the write back register data from the the 'addr' field
				regFileWE = 1'b1; // Assert write back enabled
				instrData = {5'b0, payload}; // Zero fill addr to get full address
			end

			// UNUSED
			3'b010: begin
			end

			3'b011: begin
				// Indirect
				dAddrSel = 1'b1; // Choose to use value from register file as dAddr
				regDataInSource = 1'b1; // Source the write back register data from memory
				regFileWE = 1'b1; // Assert write back enabled
			end

			// UNUSED
			3'b100: begin
			end

			// ST
			3'b101: begin
				// Indirect
				dAddrSel = 1'b1; // Choose to use value from register file as dAddr
				memWE = 1'b1; // Write to memory
			end

			// BRANCH
			3'b110: begin
				if (brFlagSel == 1'b0) begin // carry
					if (brFlag == cFlag) begin
						nextPCSel = 2'b01; // Select to use the addr field as next PC
						instrData = {{5{msbpload}}, payload}; // sign extend the addr field of the instruction
					end
				end else begin // zero
					if (brFlag == zFlag) begin
						nextPCSel = 2'b01; // Select to use the addr field as next PC
						instrData = {{5{msbpload}}, payload}; // sign extend the addr field of the instruction
					end
				end
			end

			// UNUSED
			3'b111: begin
			end
		endcase
	end
endmodule
