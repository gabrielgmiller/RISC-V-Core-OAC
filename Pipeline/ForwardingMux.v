// Pipeline/ForwardingMux.v
`timescale 1ns/100ps

module ForwardingMux (
    input wire [31:0] reg_data,      // Dado do registrador (00)
    input wire [31:0] mem_wb_data,   // Dado do MEM/WB (01)
    input wire [31:0] ex_mem_data,   // Dado do EX/MEM (10)
    input wire [1:0] forward_sel,    // Seleção do forwarding
    
    output reg [31:0] result
);

    always @(*) begin
        case (forward_sel)
            2'b00: result = reg_data;      // Sem forwarding
            2'b01: result = mem_wb_data;   // Forward do MEM/WB
            2'b10: result = ex_mem_data;   // Forward do EX/MEM
            default: result = reg_data;
        endcase
    end

endmodule
