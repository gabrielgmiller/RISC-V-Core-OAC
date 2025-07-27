module ALU_Control (
    input        ALUOp1,    // 1 = R-type, 0 = I-type / Load / Store / Branch
    input        ALUOp0,    // 1 = Branch, 0 = outros
    input  [3:0] funct,     // {funct7[5], funct3[2:0]}
    output [3:0] operation
);

    // Decodificação de tipo
    wire isR = ALUOp1 & ~ALUOp0;   // R-type
    wire isB = ~ALUOp1 &  ALUOp0;  // BEQ
    wire isI = ~ALUOp1 & ~ALUOp0;  // I-type, Load ou Store

    wire [2:0] f3   = funct[2:0];
    wire       f7_5 = funct[3];

    // Detectores refinados
    // ADD para: R-type ADD, I-type ADDI, Load (LB, LW…)
    wire sel_add = (isR & (f3 == 3'b000) & ~f7_5)
                 | (isI & (f3 != 3'b110));  

    // SUB para: R-type SUB, e também Branch BEQ
    wire sel_sub = (isR & (f3 == 3'b000) &  f7_5)
                 |  isB;            

    // AND, OR, SRL e ORI (todos I-type ORI ou R-type)
    wire sel_and = isR & (f3 == 3'b111);
    wire sel_or  = isR & (f3 == 3'b110);
    wire sel_srl = isR & (f3 == 3'b101) & ~f7_5;
    wire sel_ori = isI & (f3 == 3'b110);

    // Bit 3 sempre 0
    assign operation[3] = 1'b0;

    // Bit 2 = 1 em SUB e SRL
    assign operation[2] = sel_sub | sel_srl;

    // Bit 1 = 1 em ADD e SUB
    assign operation[1] = sel_add | sel_sub;

    // Bit 0 = 1 em OR, SRL e ORI
    assign operation[0] = sel_or  | sel_srl | sel_ori;

endmodule