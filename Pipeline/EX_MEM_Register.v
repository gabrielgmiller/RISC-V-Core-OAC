// Pipeline/EX_MEM_Register.v
`timescale 1ns/100ps

module EX_MEM_Register (
    input wire clk,
    input wire reset,
    
    // Control signals
    input wire RegWrite_in,
    input wire MemToReg_in,
    input wire MemRead_in,
    input wire MemWrite_in,
    input wire Branch_in,
    input wire Jump_in,
    
    // Data
    input wire [31:0] branch_target_in,
    input wire [31:0] alu_result_in,
    input wire [31:0] write_data_in,
    input wire [4:0] rd_in,
    input wire zero_in,
    
    // Outputs
    output reg RegWrite_out,
    output reg MemToReg_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg Branch_out,
    output reg Jump_out,
    
    output reg [31:0] branch_target_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] write_data_out,
    output reg [4:0] rd_out,
    output reg zero_out
);

    always @(posedge clk) begin
        if (reset) begin
            // Control signals
            RegWrite_out <= 1'b0;
            MemToReg_out <= 1'b0;
            MemRead_out <= 1'b0;
            MemWrite_out <= 1'b0;
            Branch_out <= 1'b0;
            Jump_out <= 1'b0;
            
            // Data
            branch_target_out <= 32'b0;
            alu_result_out <= 32'b0;
            write_data_out <= 32'b0;
            rd_out <= 5'b0;
            zero_out <= 1'b0;
        end else begin
            // Control signals
            RegWrite_out <= RegWrite_in;
            MemToReg_out <= MemToReg_in;
            MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            Branch_out <= Branch_in;
            Jump_out <= Jump_in;
            
            // Data
            branch_target_out <= branch_target_in;
            alu_result_out <= alu_result_in;
            write_data_out <= write_data_in;
            rd_out <= rd_in;
            zero_out <= zero_in;
        end
    end

endmodule
