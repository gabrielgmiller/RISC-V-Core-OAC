// Pipeline/HazardDetection.v
`timescale 1ns/100ps

module HazardDetection (
    // Inputs from ID/EX register
    input wire ID_EX_MemRead,
    input wire [4:0] ID_EX_rd,
    
    // Inputs from IF/ID register
    input wire [4:0] IF_ID_rs1,
    input wire [4:0] IF_ID_rs2,
    
    // Control outputs
    output wire PCWrite,
    output wire IF_ID_Write,
    output wire ControlMux
);

    // Load-use hazard detection
    wire load_use_hazard;
    
    assign load_use_hazard = ID_EX_MemRead && 
                            ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2)) &&
                            (ID_EX_rd != 5'b0); // x0 nunca causa hazard
    
    // Se há hazard, stall o pipeline
    assign PCWrite = ~load_use_hazard;
    assign IF_ID_Write = ~load_use_hazard;
    assign ControlMux = load_use_hazard; // 1 = inserir bolha (NOP)

endmodule
