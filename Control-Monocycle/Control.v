// Control-Monocycle/Control.v
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
    // R-type = 0110011, LB = 0000011, SB = 0100011, BEQ = 1100011, ORI = 0010011
    wire A = (Op == 7'b0110011);
    wire B = (Op == 7'b0000011);
    wire C = (Op == 7'b0100011);
    wire D = (Op == 7'b1100011);
    wire E = (Op == 7'b0010011);

    assign RegDst   = A;
    assign ALUSrc   = B | C | E;
    assign MemToReg = B;
    assign RegWrite = A | B | E;
    assign MemRead  = B;
    assign MemWrite = C;
    assign Branch   = D;
    assign ALUOp1   = A | E;
    assign ALUOp0   = D | E;
endmodule