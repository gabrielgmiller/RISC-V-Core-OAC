// ============ INCLUDES ============
`include "ClockGenerator/clock_gen.v"
`include "InstructionMemory/InstructionMemory.v"
`include "DataMemory/DataMemory.v"
`include "Registers/PC.v"
`include "Registers/Registers.v"
`include "Pipeline/ControlUnit_Pipeline.v"
`include "ImmediateGenerator/immediateG.v"
`include "Pipeline/ALU_Control_Pipeline.v"
`include "ALU/operations/and.v"
`include "ALU/operations/or.v"
`include "ALU/operations/srl.v"
`include "ALU/operations/sub.v"
`include "ALU/operations/sum.v"
`include "ALU/ALU.v"
`include "mux/mux.v"
`include "Pipeline/IF_ID_Register.v"
`include "Pipeline/ID_EX_Register.v"
`include "Pipeline/EX_MEM_Register.v"
`include "Pipeline/MEM_WB_Register.v"
`include "Pipeline/ForwardingMux.v"

module riscv_pipeline_simple (
    input reset
);
    // ============ CLOCK ============
    wire clk;
    ClockGen clkgen (.clk(clk));

    // ============ CONTROL SIGNALS ============
    // Inicializar com valores seguros
    wire PCWrite = 1'b1;  // Sempre permite escrita no PC inicialmente
    wire IF_ID_Write = 1'b1;  // Sempre permite escrita no IF/ID
    wire PCSrc = 1'b0;  // Sempre seleciona PC+4 inicialmente
    wire IF_ID_Flush = 1'b0;  // Sem flush inicialmente
    wire ID_EX_Flush = 1'b0;  // Sem flush inicialmente

    // ============ IF STAGE ============
    wire [31:0] pc_current, pc_next, pc_plus4;
    wire [31:0] instruction_if;
    wire [31:0] branch_target = 32'b0;  // Inicializar
    
    // PC MUX
    mux pc_src_mux (
        .A(branch_target),
        .B(pc_plus4),
        .select(PCSrc),
        .result(pc_next)
    );
    
    PC program_counter (
        .datain(pc_next),
        .dataout(pc_current),
        .enable(PCWrite),
        .reset(reset),
        .clk(clk)
    );
    
    sum pc_adder (
        .A(pc_current),
        .B(32'd4),
        .result(pc_plus4)
    );
    
    InstructionMemory inst_mem (
        .PC(pc_current),
        .instruction(instruction_if)
    );

    // ============ IF/ID REGISTER ============
    wire [31:0] pc_id, instruction_id;
    
    IF_ID_Register if_id_reg (
        .clk(clk),
        .reset(reset),
        .stall(~IF_ID_Write),
        .flush(IF_ID_Flush),
        .pc_in(pc_current),
        .instruction_in(instruction_if),
        .pc_out(pc_id),
        .instruction_out(instruction_id)
    );

    // ============ ID STAGE ============
    wire [31:0] read_data1_id, read_data2_id, immediate_id;
    wire [4:0] rs1_id, rs2_id, rd_id;
    wire [3:0] funct_id;
    
    // Control signals
    wire RegWrite_id, MemToReg_id, MemRead_id, MemWrite_id;
    wire ALUSrc_id, Branch_id, Jump_id;
    wire [1:0] ALUOp_id;
    
    assign rs1_id = instruction_id[19:15];
    assign rs2_id = instruction_id[24:20];
    assign rd_id = instruction_id[11:7];
    assign funct_id = {instruction_id[30], instruction_id[14:12]};
    
    ControlUnit_Pipeline control_unit (
        .Op(instruction_id[6:0]),
        .RegWrite(RegWrite_id),
        .MemToReg(MemToReg_id),
        .MemRead(MemRead_id),
        .MemWrite(MemWrite_id),
        .ALUSrc(ALUSrc_id),
        .Branch(Branch_id),
        .Jump(Jump_id),
        .ALUOp(ALUOp_id)
    );
    
    immediateG imm_gen (
        .instruction(instruction_id),
        .immediate(immediate_id)
    );
    
    // Write-back data (from WB stage)
    wire [31:0] write_data_wb_wire;
    wire [4:0] rd_wb_wire;
    wire RegWrite_wb_wire;
    
    Registers reg_file (
        .readRegister1(rs1_id),
        .readRegister2(rs2_id),
        .writeRegister(rd_wb_wire),
        .writeData(write_data_wb_wire),
        .regWrite(RegWrite_wb_wire),
        .clk(clk),
        .readData1(read_data1_id),
        .readData2(read_data2_id)
    );

    // ============ ID/EX REGISTER ============
    wire [31:0] pc_ex, read_data1_ex, read_data2_ex, immediate_ex;
    wire [4:0] rs1_ex, rs2_ex, rd_ex;
    wire [3:0] funct_ex;
    wire RegWrite_ex, MemToReg_ex, MemRead_ex, MemWrite_ex;
    wire ALUSrc_ex, Branch_ex, Jump_ex;
    wire [1:0] ALUOp_ex;
    
    ID_EX_Register id_ex_reg (
        .clk(clk),
        .reset(reset),
        .flush(ID_EX_Flush),
        .RegWrite_in(RegWrite_id),
        .MemToReg_in(MemToReg_id),
        .MemRead_in(MemRead_id),
        .MemWrite_in(MemWrite_id),
        .ALUSrc_in(ALUSrc_id),
        .Branch_in(Branch_id),
        .Jump_in(Jump_id),
        .ALUOp_in(ALUOp_id),
        .pc_in(pc_id),
        .read_data1_in(read_data1_id),
        .read_data2_in(read_data2_id),
        .immediate_in(immediate_id),
        .rs1_in(rs1_id),
        .rs2_in(rs2_id),
        .rd_in(rd_id),
        .funct_in(funct_id),
        .RegWrite_out(RegWrite_ex),
        .MemToReg_out(MemToReg_ex),
        .MemRead_out(MemRead_ex),
        .MemWrite_out(MemWrite_ex),
        .ALUSrc_out(ALUSrc_ex),
        .Branch_out(Branch_ex),
        .Jump_out(Jump_ex),
        .ALUOp_out(ALUOp_ex),
        .pc_out(pc_ex),
        .read_data1_out(read_data1_ex),
        .read_data2_out(read_data2_ex),
        .immediate_out(immediate_ex),
        .rs1_out(rs1_ex),
        .rs2_out(rs2_ex),
        .rd_out(rd_ex),
        .funct_out(funct_ex)
    );

    // ============ EX STAGE ============
    wire [31:0] alu_input1, alu_input2, alu_result;
    wire [3:0] alu_control;
    wire zero;
    
    // Sem forwarding por enquanto - usar dados diretos
    assign alu_input1 = read_data1_ex;
    
    mux alu_src_mux (
        .A(immediate_ex),
        .B(read_data2_ex),
        .select(ALUSrc_ex),
        .result(alu_input2)
    );
    
    ALU_Control_Pipeline alu_ctrl (
        .ALUOp(ALUOp_ex),
        .funct(funct_ex),
        .operation(alu_control)
    );
    
    ALU alu_unit (
        .A(alu_input1),
        .B(alu_input2),
        .ALUOp(alu_control),
        .result(alu_result),
        .zero(zero)
    );

    // ============ EX/MEM REGISTER ============
    wire [31:0] alu_result_mem, write_data_mem;
    wire [4:0] rd_mem;
    wire RegWrite_mem, MemToReg_mem, MemRead_mem, MemWrite_mem;
    
    EX_MEM_Register ex_mem_reg (
        .clk(clk),
        .reset(reset),
        .RegWrite_in(RegWrite_ex),
        .MemToReg_in(MemToReg_ex),
        .MemRead_in(MemRead_ex),
        .MemWrite_in(MemWrite_ex),
        .Branch_in(1'b0),  // Simplificar
        .Jump_in(1'b0),    // Simplificar
        .branch_target_in(32'b0),
        .alu_result_in(alu_result),
        .write_data_in(read_data2_ex),
        .rd_in(rd_ex),
        .zero_in(zero),
        .RegWrite_out(RegWrite_mem),
        .MemToReg_out(MemToReg_mem),
        .MemRead_out(MemRead_mem),
        .MemWrite_out(MemWrite_mem),
        .Branch_out(),
        .Jump_out(),
        .branch_target_out(),
        .alu_result_out(alu_result_mem),
        .write_data_out(write_data_mem),
        .rd_out(rd_mem),
        .zero_out()
    );

    // ============ MEM STAGE ============
    wire [31:0] read_data_mem;
    
    data_memory data_mem (
        .clk(clk),
        .mem_read(MemRead_mem),
        .mem_write(MemWrite_mem),
        .endereco(alu_result_mem),
        .write_data(write_data_mem),
        .read_data(read_data_mem)
    );

    // ============ MEM/WB REGISTER ============
    wire [31:0] read_data_wb_reg, alu_result_wb;
    wire MemToReg_wb_reg;
    
    MEM_WB_Register mem_wb_reg (
        .clk(clk),
        .reset(reset),
        .RegWrite_in(RegWrite_mem),
        .MemToReg_in(MemToReg_mem),
        .read_data_in(read_data_mem),
        .alu_result_in(alu_result_mem),
        .rd_in(rd_mem),
        .RegWrite_out(RegWrite_wb_wire),
        .MemToReg_out(MemToReg_wb_reg),
        .read_data_out(read_data_wb_reg),
        .alu_result_out(alu_result_wb),
        .rd_out(rd_wb_wire)
    );

    // ============ WB STAGE ============
    mux wb_mux (
        .A(read_data_wb_reg),
        .B(alu_result_wb),
        .select(MemToReg_wb_reg),
        .result(write_data_wb_wire)
    );

endmodule
