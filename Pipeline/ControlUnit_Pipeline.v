// Pipeline/ControlUnit_Pipeline.v
`timescale 1ns/100ps

module ControlUnit_Pipeline (
    input  [6:0] Op,
    output       RegWrite,
    output       MemToReg,
    output       MemRead,
    output       MemWrite,
    output       ALUSrc,
    output       Branch,
    output       Jump,
    output [1:0] ALUOp
);
    // Tipos de instrução:
    // R-type = 0110011 (sub, and, srl)
    // I-type aritmético = 0010011 (addi, ori) 
    // Load = 0000011 (lb)
    // Store = 0100011 (sb)
    // Branch = 1100011 (beq)
    // Jump = 1101111 (j)
    
    wire R_type = (Op == 7'b0110011);
    wire I_arith = (Op == 7'b0010011);
    wire Load = (Op == 7'b0000011);
    wire Store = (Op == 7'b0100011);
    wire Branch_type = (Op == 7'b1100011);
    wire Jump_type = (Op == 7'b1101111);

    assign RegWrite = R_type | I_arith | Load;   // Escreve no banco de registradores
    assign MemToReg = Load;                      // Escreve dado da memória no registrador
    assign MemRead  = Load;                      // Lê da memória
    assign MemWrite = Store;                     // Escreve na memória
    assign ALUSrc   = I_arith | Load | Store;    // Usa imediato
    assign Branch   = Branch_type;               // Instrução de branch
    assign Jump     = Jump_type;                 // Instrução de jump
    
    // ALUOp encoding: 00=Load/Store, 01=Branch, 10=R-type, 11=I-type
    assign ALUOp[1] = R_type | I_arith;
    assign ALUOp[0] = Branch_type | I_arith;

endmodule
