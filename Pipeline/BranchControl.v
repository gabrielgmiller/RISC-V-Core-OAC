// Pipeline/BranchControl.v
`timescale 1ns/100ps

module BranchControl (
    input wire Branch,
    input wire Jump,
    input wire zero,
    
    output wire PCSrc,
    output wire IF_ID_Flush,
    output wire ID_EX_Flush
);

    wire branch_taken;
    
    assign branch_taken = Branch & zero;
    assign PCSrc = branch_taken | Jump;
    
    // Se branch/jump é tomado, flush os estágios anteriores
    assign IF_ID_Flush = PCSrc;
    assign ID_EX_Flush = PCSrc;

endmodule
