module ALU(input clk, // Note we need a clock and reset for the Z register
           input rst,
           input [15:0] in1,
           input [15:0] in2,
           input op, // Adding more functions to the system means adding bits to this
           output reg [15:0] out,
           output reg zFlag);

  reg zFlagNext;

  // Z flag register
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      zFlag <= 1'b0;
    end
    else begin
      zFlag <= zFlagNext;
    end
  end

  // ALU Logic
  always @(*) begin
    // Defaults -- I do this to: 1) make sure there are no latches, 2) list all
    // variables set by this block
    out = 16'd0;
    zFlagNext = zFlag; // Note, according to our ISA, the z flag only changes when an ADD is performed, otherwise it should retain its value

    case (op)
    // Note aluOp == 0 is not mapped to anything, it could be mapped to more
    // operations later, but for now theres no logic needed behind it
    // ADD
    1: begin
      out = in1 + in2;
      zFlagNext = (out == 16'd0);
    end
    endcase
  end

endmodule

module registerFile(input clk,
                    input rst,
                    input [15:0] in,     // Data for write back register
                    input [1:0] inSel,   // Register number to write back to
                    input inEn,          // Dont actually write back unless asserted
                    input [1:0] outSel1, // Register number for out1
                    input [1:0] outSel2, // Register number for out2
                    output [15:0] out1,
                    output [15:0] out2);

  reg [15:0] regs[3:0];

  // Actual register file storage
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      regs[3] <= 16'd0;
      regs[2] <= 16'd0;
      regs[1] <= 16'd0;
      regs[0] <= 16'd0;
    end
    else begin
      if (inEn) begin // Only write back when inEn is asserted, not all instructions write to the register file!
        regs[inSel] <= in;
      end
    end
  end

  // Output registers
  assign out1 = regs[outSel1];
  assign out2 = regs[outSel2];

endmodule

module memory(input clk,
              input [15:0] iAddr, // These next two signals form the instruction port
              output [15:0] iDataOut,
              input [15:0] dAddr, // These next four signals form the data port
              input dWE,
              input [15:0] dDataIn,
              output [15:0] dDataOut);

       reg [15:0] memArray [1023:0]; // Notice that Im not filling in all of memory with the memory array, ie, addresses can only from $0000 to $03ff

        initial begin
          // Load in the program/initial memory state into the memory module
          $readmemh("program.hex", memArray);
        end

        always @(posedge clk) begin
          if (dWE) begin // When the WE line is asserted, write into memory at the given address
            memArray[dAddr[9:0]] <= dDataIn; // Limit the range of the addresses
          end
        end

        assign dDataOut = memArray[dAddr[9:0]];
        assign iDataOut = memArray[iAddr[9:0]];

endmodule

module decoder(input [15:0] instruction,
           input zFlag,
           output reg [1:0] nextPCSel,
           output reg regInSource,
           output [1:0] regInSel,
           output reg regInEn,
           output [1:0] regOutSel1,
           output [1:0] regOutSel2,
           output reg aluOp,
           output reg dWE,
           output reg dAddrSel,
           output reg [15:0] addr);

  // Notice all instructions are designed in such a way that the instruction can
  // be parsed to get the registers out, even if a given instruction does not
  // use that register. The rest of the control signals will ensure nothing goes
  // wrong
  assign regInSel = instruction[13:12];
  assign regOutSel1 = instruction[11:10];
  assign regOutSel2 = instruction[9:8];

  always @(*) begin
    // Defaults
    nextPCSel = 2'b0;

    regInSource = 1'b0;
    regInEn = 1'b0;

    aluOp = 1'b0;

    dAddrSel = 1'b0;
    dWE = 1'b0;

    addr = 16'd0;

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
        addr = {6'b0, instruction[11:1]}; // Zero fill addr to get full address
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
        addr = {6'b0, instruction[13:10], instruction[7:1]}; // Zero fill addr to get full address
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
          addr = {{6{instruction[11]}}, instruction[11:1]}; // sign extend the addr field of the instruction
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

module processor(input clk,
         input rst);

  wire [15:0] dAddr;
  wire [15:0] dDataOut;
  wire dWE;
  wire dAddrSel;

  wire [15:0] addr;

  wire [15:0] regIn;
  wire [1:0] regInSel;
  wire regInEn;
  wire regInSource;
  wire [1:0] regOutSel1;
  wire [1:0] regOutSel2;
  wire [15:0] regOut1;
  wire [15:0] regOut2;

  wire aluOp;
  wire zFlag;
  wire [15:0] aluOut;

  wire [1:0] nextPCSel;
  reg [15:0] PC;
  reg [15:0] nextPC;

  wire [15:0] instruction;


  // Instatiate all of our components
  memory mem(.clk(clk),
         .iAddr(PC), // The instruction port uses the PC as its address and outputs the current instruction, so connect these directly
         .iDataOut(instruction),
         .dAddr(dAddr),
         .dWE(dWE),
         .dDataIn(regOut2), // In all instructions, only source register 2 is ever written to memory, so make this connection direct
         .dDataOut(dDataOut));

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
