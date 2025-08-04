// Pipeline/ID_EX_Register.v
`timescale 1ns/100ps

module ID_EX_Register (
    input wire clk,
    input wire reset,
    input wire flush,
    
    // Control signals
    input wire RegWrite_in,
    input wire MemToReg_in,
    input wire MemRead_in,
    input wire MemWrite_in,
    input wire ALUSrc_in,
    input wire Branch_in,
    input wire Jump_in,
    input wire [1:0] ALUOp_in,
    
    // Data
    input wire [31:0] pc_in,
    input wire [31:0] read_data1_in,
    input wire [31:0] read_data2_in,
    input wire [31:0] immediate_in,
    input wire [4:0] rs1_in,
    input wire [4:0] rs2_in,
    input wire [4:0] rd_in,
    input wire [3:0] funct_in,
    
    // Outputs
    output reg RegWrite_out,
    output reg MemToReg_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg ALUSrc_out,
    output reg Branch_out,
    output reg Jump_out,
    output reg [1:0] ALUOp_out,
    
    output reg [31:0] pc_out,
    output reg [31:0] read_data1_out,
    output reg [31:0] read_data2_out,
    output reg [31:0] immediate_out,
    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,
    output reg [4:0] rd_out,
    output reg [3:0] funct_out
);

    always @(posedge clk) begin
        if (reset || flush) begin
            // Control signals
            RegWrite_out <= 1'b0;
            MemToReg_out <= 1'b0;
            MemRead_out <= 1'b0;
            MemWrite_out <= 1'b0;
            ALUSrc_out <= 1'b0;
            Branch_out <= 1'b0;
            Jump_out <= 1'b0;
            ALUOp_out <= 2'b00;
            
            // Data
            pc_out <= 32'b0;
            read_data1_out <= 32'b0;
            read_data2_out <= 32'b0;
            immediate_out <= 32'b0;
            rs1_out <= 5'b0;
            rs2_out <= 5'b0;
            rd_out <= 5'b0;
            funct_out <= 4'b0;
        end else begin
            // Control signals
            RegWrite_out <= RegWrite_in;
            MemToReg_out <= MemToReg_in;
            MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            ALUSrc_out <= ALUSrc_in;
            Branch_out <= Branch_in;
            Jump_out <= Jump_in;
            ALUOp_out <= ALUOp_in;
            
            // Data
            pc_out <= pc_in;
            read_data1_out <= read_data1_in;
            read_data2_out <= read_data2_in;
            immediate_out <= immediate_in;
            rs1_out <= rs1_in;
            rs2_out <= rs2_in;
            rd_out <= rd_in;
            funct_out <= funct_in;
        end
    end

endmodule
