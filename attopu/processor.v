module processor(
	input clk,
  input rst,
  output dWE,
  output [15:0] dAddr,
  output [15:0] regOut2,
  output reg [15:0] PC,
  input [15:0] dDataOut,
  input [15:0] instruction
);

  wire dAddrSel;

  wire [15:0] addr;

  wire [15:0] regIn;
  wire [1:0] regInSel;
  wire regInEn;
  wire regInSource;
  wire [1:0] regOutSel1;
  wire [1:0] regOutSel2;
  wire [15:0] regOut1;

  wire aluOp;
  wire zFlag;
  wire [15:0] aluOut;

  wire [1:0] nextPCSel;
  reg [15:0] nextPC;

  registerFile regFile(.clk(clk),
               .rst(rst),
               .in(regIn),
               .inSel(regInSel),
               .inEn(regInEn),
               .outSel1(regOutSel1),
               .outSel2(regOutSel2),
               .out1(regOut1),
               .out2(regOut2));

  ALU alu(.clk(clk),
      .rst(rst),
      .in1(regOut1),
      .in2(regOut2),
      .op(aluOp),
      .out(aluOut),
      .zFlag(zFlag));

  decoder decode(.instruction(instruction),
         .zFlag(zFlag),
         .nextPCSel(nextPCSel),
         .regInSource(regInSource),
         .regInSel(regInSel),
         .regInEn(regInEn),
         .regOutSel1(regOutSel1),
         .regOutSel2(regOutSel2),
         .aluOp(aluOp),
         .dWE(dWE),
         .dAddrSel(dAddrSel),
         .addr(addr));

  // PC Logic
  always @(*) begin
    nextPC = 16'd0;

    casez (nextPCSel)
    // From register file
    2'b1?: begin
      nextPC = regOut1;
    end

    // From instruction relative
    2'b01: begin
      nextPC = PC + addr;
    end

    // Regular operation, increment
    default: begin
      nextPC = PC + 16'd1;
    end
    endcase
  end

  // PC Register
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      PC <= 16'd0;
    end
    else begin
      PC <= nextPC;
    end
  end

  // Extra logic
  assign regIn = (regInSource) ? dDataOut : aluOut;
  assign dAddr = (dAddrSel) ? regOut1 : addr;
endmodule

module processor_top(
	input clk,
  input rst,
	output [7:0] led
);

  wire dWE;
  wire [15:0] dAddr;
  wire [15:0] regOut2;
  wire [15:0] dDataOut;
  wire [15:0] instruction;
  wire [15:0] PC;

processor attopu(
	.clk(clk),
  .rst(rst),
  .dWE(dWE),
  .dAddr(dAddr),
  .regOut2(regOut2),
  .PC(PC),
  .dDataOut(DataOut),
  .instruction(instruction)
);

	reg [15:0] ram[0:1023];
	reg [15:0] rom[0:1023];
	initial
		$readmemh("program.hex", rom);

	// In all instructions, only source register 2 is ever written to memory, so
	// make this connection direct
	always @(posedge clk)
		if (dWE) begin
			ram[dAddr] <= regOut2;
		end

	// The instruction port uses the PC as its address and outputs the current
	// instruction, so connect these directly
	assign instruction = rom[PC];
	assign dDataOut = ram[dAddr];

	assign led = PC[7:0];
endmodule
