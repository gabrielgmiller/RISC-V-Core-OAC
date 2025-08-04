// Pipeline/MEM_WB_Register.v
`timescale 1ns/100ps

module MEM_WB_Register (
    input wire clk,
    input wire reset,
    
    // Control signals
    input wire RegWrite_in,
    input wire MemToReg_in,
    
    // Data
    input wire [31:0] read_data_in,
    input wire [31:0] alu_result_in,
    input wire [4:0] rd_in,
    
    // Outputs
    output reg RegWrite_out,
    output reg MemToReg_out,
    
    output reg [31:0] read_data_out,
    output reg [31:0] alu_result_out,
    output reg [4:0] rd_out
);

    always @(posedge clk) begin
        if (reset) begin
            // Control signals
            RegWrite_out <= 1'b0;
            MemToReg_out <= 1'b0;
            
            // Data
            read_data_out <= 32'b0;
            alu_result_out <= 32'b0;
            rd_out <= 5'b0;
        end else begin
            // Control signals
            RegWrite_out <= RegWrite_in;
            MemToReg_out <= MemToReg_in;
            
            // Data
            read_data_out <= read_data_in;
            alu_result_out <= alu_result_in;
            rd_out <= rd_in;
        end
    end

endmodule
