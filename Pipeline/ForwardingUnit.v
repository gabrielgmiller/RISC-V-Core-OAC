// Pipeline/ForwardingUnit.v
`timescale 1ns/100ps

module ForwardingUnit (
    // Inputs from EX/MEM register
    input wire EX_MEM_RegWrite,
    input wire [4:0] EX_MEM_rd,
    
    // Inputs from MEM/WB register
    input wire MEM_WB_RegWrite,
    input wire [4:0] MEM_WB_rd,
    
    // Inputs from ID/EX register
    input wire [4:0] ID_EX_rs1,
    input wire [4:0] ID_EX_rs2,
    
    // Forwarding control outputs
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

    always @(*) begin
        // Default: no forwarding
        ForwardA = 2'b00;
        ForwardB = 2'b00;
        
        // EX hazard (forwarding from EX/MEM)
        if (EX_MEM_RegWrite && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs1)) begin
            ForwardA = 2'b10;
        end
        if (EX_MEM_RegWrite && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs2)) begin
            ForwardB = 2'b10;
        end
        
        // MEM hazard (forwarding from MEM/WB)
        if (MEM_WB_RegWrite && (MEM_WB_rd != 5'b0) && 
            !(EX_MEM_RegWrite && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs1)) &&
            (MEM_WB_rd == ID_EX_rs1)) begin
            ForwardA = 2'b01;
        end
        if (MEM_WB_RegWrite && (MEM_WB_rd != 5'b0) && 
            !(EX_MEM_RegWrite && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs2)) &&
            (MEM_WB_rd == ID_EX_rs2)) begin
            ForwardB = 2'b01;
        end
    end

endmodule
