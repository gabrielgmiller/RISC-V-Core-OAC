// Pipeline/ALU_Control_Pipeline.v
`timescale 1ns/100ps

module ALU_Control_Pipeline (
    input [1:0] ALUOp,      // 00=Load/Store, 01=Branch, 10=R-type, 11=I-type
    input [3:0] funct,      // {funct7[5], funct3[2:0]}
    output [3:0] operation
);

    wire [2:0] f3 = funct[2:0];
    wire f7_5 = funct[3];

    wire isLS = (ALUOp == 2'b00);  // Load/Store
    wire isBranch = (ALUOp == 2'b01);  // Branch
    wire isR = (ALUOp == 2'b10);   // R-type
    wire isI = (ALUOp == 2'b11);   // I-type

    // Seleção das operações
    wire sel_add = (isR & (f3 == 3'b000) & ~f7_5) |  // ADD
                   (isI & (f3 == 3'b000)) |           // ADDI
                   isLS;                               // Load/Store (sempre soma)
    wire sel_sub = (isR & (f3 == 3'b000) & f7_5) |   // SUB
                   isBranch;                           // BEQ (subtração para comparação)
    wire sel_and = isR & (f3 == 3'b111);              // AND
    wire sel_or  = isR & (f3 == 3'b110);              // OR
    wire sel_srl = isR & (f3 == 3'b101) & ~f7_5;      // SRL
    wire sel_ori = isI & (f3 == 3'b110);              // ORI

    // Codificação das operações da ALU
    // 0010 = ADD, 0110 = SUB, 0000 = AND, 0001 = OR, 0101 = SRL
    assign operation[3] = 1'b0;
    assign operation[2] = sel_sub | sel_srl;
    assign operation[1] = sel_add | sel_sub;
    assign operation[0] = sel_or | sel_srl | sel_ori;

endmodule
