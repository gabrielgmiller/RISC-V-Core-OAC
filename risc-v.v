// ============ CLOCK & MEMÓRIAS ============
`include "ClockGenerator/clock_gen.v"
`include "InstructionMemory/InstructionMemory.v"
`include "DataMemory/DataMemory.v"

// ============ REGISTROS ============
`include "Registers/PC.v"
`include "Registers/Registers.v"

// ============ CONTROL ============
`include "Control-Monocycle/Control.v"
`include "ImmediateGenerator/immediateG.v"
`include "ALU_Control/ALU_Control_structural.v"

// ============ ALU & OPERATIONS ============
`include "ALU/operations/and.v"
`include "ALU/operations/or.v"
`include "ALU/operations/srl.v"
`include "ALU/operations/sub.v"
`include "ALU/operations/sum.v"
`include "ALU/ALU.v"

// ============ MUX ============
`include "mux/mux.v"

module riscv (
    input reset
);
    // relógio interno
    wire        clk;

    // Programa Counter
    wire [31:0] nextPCPosition;
    wire [31:0] instructionAddress;

    // Instrução atual
    wire [31:0] instructionCurrent;

    // Sinais de controle
    wire        RegDst;
    wire        ALUSrc;
    wire        MemToReg;
    wire        RegWrite;
    wire        MemRead;
    wire        MemWrite;
    wire        Branch;
    wire        Jump;
    wire        ALUOp1;
    wire        ALUOp0;

    // Registrador / Write-back
    wire [31:0] dataToWrite;
    wire [31:0] dataReadRegister1;
    wire [31:0] dataReadRegister2;

    // Immediate e ALU Control
    wire [31:0] imm;
    wire [3:0]  ALUOp;

    // ALU
    wire [31:0] ndInputALU;
    wire [31:0] ALUResult;
    wire        zero;

    // Data Memory
    wire [31:0] dataReadFromMemory;

    // Branch logic
    wire        andBranch;

    // Adder para branch e para PC+1
    wire [31:0] resAdderA;
    wire [31:0] resAdderB;

    // instâncias
    ClockGen           clkgen      (.clk(clk));
    PC                 programCounter (
                          .datain(nextPCPosition),
                          .dataout(instructionAddress),
                          .enable(1'b1),
                          .reset(reset),
                          .clk(clk)
                        );
    sum                adderB (
                          .A(instructionAddress),
                          .B(32'd4),
                          .result(resAdderB)
                        );
    InstructionMemory  instmemo   (
                          .PC(instructionAddress),
                          .instruction(instructionCurrent)
                        );
    ControlUnit        control    (
                          .Op(instructionCurrent[6:0]),
                          .RegDst(RegDst),
                          .ALUSrc(ALUSrc),
                          .MemToReg(MemToReg),
                          .RegWrite(RegWrite),
                          .MemRead(MemRead),
                          .MemWrite(MemWrite),
                          .Branch(Branch),
                          .Jump(Jump),
                          .ALUOp1(ALUOp1),
                          .ALUOp0(ALUOp0)
                        );
    ALU_Control        aluctrl    (
                          .ALUOp1(ALUOp1),
                          .ALUOp0(ALUOp0),
                          .funct({instructionCurrent[30], instructionCurrent[14:12]}),
                          .operation(ALUOp)
                        );
    immediateG         immgen     (
                          .instruction(instructionCurrent),
                          .immediate(imm)
                        );
    sum                adderA     (
                          .A(instructionAddress),
                          .B(imm),
                          .result(resAdderA)
                        );
    data_memory        datamem    (
                          .clk(clk),
                          .mem_read(MemRead),
                          .mem_write(MemWrite),
                          .endereco(ALUResult),
                          .write_data(dataReadRegister2),
                          .read_data(dataReadFromMemory)
                        );
    Registers          regs       (
                          .readRegister1(instructionCurrent[19:15]),
                          .readRegister2(instructionCurrent[24:20]),
                          .writeRegister(instructionCurrent[11:7]),
                          .writeData(dataToWrite),
                          .regWrite(RegWrite),
                          .clk(clk),
                          .readData1(dataReadRegister1),
                          .readData2(dataReadRegister2)
                        );
    mux                muxC       (
                          .A(imm),
                          .B(dataReadRegister2),
                          .select(ALUSrc),
                          .result(ndInputALU)
                        );
    ALU                alu        (
                          .A(dataReadRegister1),
                          .B(ndInputALU),
                          .ALUOp(ALUOp),
                          .result(ALUResult),
                          .zero(zero)
                        );
    and                branch_and (
                          andBranch,
                          Branch,
                          zero
                        );
    wire               orJump = andBranch | Jump;
    mux                muxA       (
                          .A(resAdderA),
                          .B(resAdderB),
                          .select(orJump),
                          .result(nextPCPosition)
                        );
    mux                muxB       (
                          .A(dataReadFromMemory),
                          .B(ALUResult),
                          .select(MemToReg),
                          .result(dataToWrite)
                        );

endmodule