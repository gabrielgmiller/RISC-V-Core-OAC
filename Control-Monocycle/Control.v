module ControlUnit (
    input  [6:0] Op,
    output       RegDst,
    output       ALUSrc,
    output       MemToReg,
    output       RegWrite,
    output       MemRead,
    output       MemWrite,
    output       Branch,
    output       ALUOp1,
    output       ALUOp0
);

    // Para cada opcode, levantamos um wire:
    // A = R-type (0110011)
    // B = LB      (0000011)
    // C = SB      (0100011)
    // D = BEQ     (1100011)
    // E = ORI     (0010011)
    wire A, B, C, D, E;
    wire [6:0] OpNeg = ~Op;

    and (A, OpNeg[6],  Op[5],  Op[4],  OpNeg[3], OpNeg[2], Op[1], Op[0]);
    and (B, OpNeg[6],  OpNeg[5],OpNeg[4],OpNeg[3], OpNeg[2],Op[1], Op[0]);
    and (C, OpNeg[6],  Op[5],  OpNeg[4],OpNeg[3], OpNeg[2],Op[1], Op[0]);
    and (D,  Op[6],    Op[5],  OpNeg[4],OpNeg[3], OpNeg[2],Op[1], Op[0]);
    and (E,  OpNeg[6], OpNeg[5],Op[4],  OpNeg[3], OpNeg[2],Op[1], Op[0]);

    // RegDst = 1 só para R-type
    assign RegDst   = A;
    // ALUSrc = 1 para LB, SB e ORI (imediatos)
    or     (ALUSrc,  B, C, E);
    // MemToReg = 1 apenas para LB
    assign MemToReg = B;
    // RegWrite = 1 para R-type, LB e ORI
    or     (RegWrite, A, B, E);
    // MemRead  = 1 só para LB
    assign MemRead  = B;
    // MemWrite = 1 só para SB
    assign MemWrite = C;
    // Branch   = 1 só para BEQ
    assign Branch   = D;
    // ALUOp = 10 para R-type; 00 para LB/SB; 01 para BEQ; 11 para ORI
    assign ALUOp1   = A | E;
    assign ALUOp0   = D | E;

endmodule