// ALU_Control/ALU_Control_structural.v
module ALU_Control (
    input        ALUOp1,    // 1 = R-type/I-type aritmético, 0 = Load/Store/Branch
    input        ALUOp0,    // 1 = Branch/I-type lógico, 0 = outros
    input  [3:0] funct,     // {funct7[5], funct3[2:0]}
    output [3:0] operation
);

    wire isR = ALUOp1 & ~ALUOp0;   // R-type (0110011)
    wire isB = ~ALUOp1 &  ALUOp0;  // BEQ (1100011)
    wire isLS = ~ALUOp1 & ~ALUOp0; // Load/Store (0000011, 0100011)
    wire isI = ALUOp1 & ALUOp0;    // I-type (0010011)

    wire [2:0] f3   = funct[2:0];
    wire       f7_5 = funct[3];

    // Seleção das operações
    wire sel_add = (isR & (f3 == 3'b000) & ~f7_5) |  // ADD
                   (isI & (f3 == 3'b000)) |           // ADDI
                   isLS;                               // Load/Store (sempre soma)
    wire sel_sub = (isR & (f3 == 3'b000) &  f7_5) |  // SUB
                   isB;                                // BEQ (subtração para comparação)
    wire sel_and =  isR & (f3 == 3'b111);             // AND
    wire sel_or  =  isR & (f3 == 3'b110);             // OR
    wire sel_srl =  isR & (f3 == 3'b101) & ~f7_5;     // SRL
    wire sel_ori =  isI & (f3 == 3'b110);             // ORI

    // Codificação das operações da ALU
    // 0010 = ADD, 0110 = SUB, 0000 = AND, 0001 = OR, 0101 = SRL
    assign operation[3] = 1'b0;
    assign operation[2] = sel_sub | sel_srl;
    assign operation[1] = sel_add | sel_sub;
    assign operation[0] = sel_or | sel_srl | sel_ori;

endmodule