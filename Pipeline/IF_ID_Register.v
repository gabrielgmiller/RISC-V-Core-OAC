// Pipeline/IF_ID_Register.v
`timescale 1ns/100ps

module IF_ID_Register (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,
    
    // Inputs from IF stage
    input wire [31:0] pc_in,
    input wire [31:0] instruction_in,
    
    // Outputs to ID stage
    output reg [31:0] pc_out,
    output reg [31:0] instruction_out
);

    always @(posedge clk) begin
        if (reset || flush) begin
            pc_out <= 32'b0;
            instruction_out <= 32'h00000013; // NOP
        end else if (!stall) begin
            pc_out <= pc_in;
            instruction_out <= instruction_in;
        end
        // Se stall=1, mantém os valores atuais
    end

endmodule
