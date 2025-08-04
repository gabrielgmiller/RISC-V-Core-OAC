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
`include "Pipeline/ForwardingUnit.v"
`include "Pipeline/ForwardingMux.v"
`include "Pipeline/HazardDetection.v"
`include "Pipeline/BranchControl.v"

module riscv_pipeline_complete (
    input reset
);
    // ============ CLOCK ============
    wire clk;
    ClockGen clkgen (.clk(clk));

    // ============ CONTROL SIGNALS ============
    wire PCWrite, IF_ID_Write, ControlMux;
    wire IF_ID_Flush, ID_EX_Flush, PCSrc;

    // ============ IF STAGE ============
    wire [31:0] pc_current, pc_next, pc_plus4;
    wire [31:0] instruction_if;
    wire [31:0] branch_target_mem;
    
    // PC MUX
    mux pc_src_mux (
        .A(branch_target_mem),
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
    wire [31:0] write_data_wb;
    wire [4:0] rd_wb;
    wire RegWrite_wb;
    
    Registers reg_file (
        .readRegister1(rs1_id),
        .readRegister2(rs2_id),
        .writeRegister(rd_wb),
        .writeData(write_data_wb),
        .regWrite(RegWrite_wb),
        .clk(clk),
        .readData1(read_data1_id),
        .readData2(read_data2_id)
    );

    // ============ HAZARD DETECTION ============
    wire ID_EX_MemRead_wire;
    wire [4:0] ID_EX_rd_wire;
    
    HazardDetection hazard_unit (
        .ID_EX_MemRead(ID_EX_MemRead_wire),
        .ID_EX_rd(ID_EX_rd_wire),
        .IF_ID_rs1(rs1_id),
        .IF_ID_rs2(rs2_id),
        .PCWrite(PCWrite),
        .IF_ID_Write(IF_ID_Write),
        .ControlMux(ControlMux)
    );

    // Control MUX (para inserir bolhas)
    wire RegWrite_id_mux, MemToReg_id_mux, MemRead_id_mux, MemWrite_id_mux;
    wire ALUSrc_id_mux, Branch_id_mux, Jump_id_mux;
    wire [1:0] ALUOp_id_mux;
    
    assign RegWrite_id_mux = ControlMux ? 1'b0 : RegWrite_id;
    assign MemToReg_id_mux = ControlMux ? 1'b0 : MemToReg_id;
    assign MemRead_id_mux = ControlMux ? 1'b0 : MemRead_id;
    assign MemWrite_id_mux = ControlMux ? 1'b0 : MemWrite_id;
    assign ALUSrc_id_mux = ControlMux ? 1'b0 : ALUSrc_id;
    assign Branch_id_mux = ControlMux ? 1'b0 : Branch_id;
    assign Jump_id_mux = ControlMux ? 1'b0 : Jump_id;
    assign ALUOp_id_mux = ControlMux ? 2'b00 : ALUOp_id;

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
        .RegWrite_in(RegWrite_id_mux),
        .MemToReg_in(MemToReg_id_mux),
        .MemRead_in(MemRead_id_mux),
        .MemWrite_in(MemWrite_id_mux),
        .ALUSrc_in(ALUSrc_id_mux),
        .Branch_in(Branch_id_mux),
        .Jump_in(Jump_id_mux),
        .ALUOp_in(ALUOp_id_mux),
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
    
    // Conectar sinais para hazard detection
    assign ID_EX_MemRead_wire = MemRead_ex;
    assign ID_EX_rd_wire = rd_ex;

    // ============ EX STAGE ============
    wire [31:0] alu_input1, alu_input2, alu_result;
    wire [3:0] alu_control;
    wire zero;
    wire [31:0] branch_target;
    
    // Forwarding signals
    wire [1:0] ForwardA, ForwardB;
    wire [31:0] forward_data1, forward_data2;
    wire [31:0] ex_mem_alu_result;
    wire EX_MEM_RegWrite_wire;
    wire [4:0] EX_MEM_rd_wire;
    
    ForwardingUnit forward_unit (
        .EX_MEM_RegWrite(EX_MEM_RegWrite_wire),
        .EX_MEM_rd(EX_MEM_rd_wire),
        .MEM_WB_RegWrite(RegWrite_wb),
        .MEM_WB_rd(rd_wb),
        .ID_EX_rs1(rs1_ex),
        .ID_EX_rs2(rs2_ex),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );
    
    ForwardingMux forward_mux_a (
        .reg_data(read_data1_ex),
        .mem_wb_data(write_data_wb),
        .ex_mem_data(ex_mem_alu_result),
        .forward_sel(ForwardA),
        .result(forward_data1)
    );
    
    ForwardingMux forward_mux_b (
        .reg_data(read_data2_ex),
        .mem_wb_data(write_data_wb),
        .ex_mem_data(ex_mem_alu_result),
        .forward_sel(ForwardB),
        .result(forward_data2)
    );
    
    assign alu_input1 = forward_data1;
    
    mux alu_src_mux (
        .A(immediate_ex),
        .B(forward_data2),
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
    
    sum branch_adder (
        .A(pc_ex),
        .B(immediate_ex),
        .result(branch_target)
    );

    // ============ EX/MEM REGISTER ============
    wire [31:0] alu_result_mem, write_data_mem;
    wire [4:0] rd_mem;
    wire RegWrite_mem, MemToReg_mem, MemRead_mem, MemWrite_mem;
    wire Branch_mem, Jump_mem, zero_mem;
    
    EX_MEM_Register ex_mem_reg (
        .clk(clk),
        .reset(reset),
        .RegWrite_in(RegWrite_ex),
        .MemToReg_in(MemToReg_ex),
        .MemRead_in(MemRead_ex),
        .MemWrite_in(MemWrite_ex),
        .Branch_in(Branch_ex),
        .Jump_in(Jump_ex),
        .branch_target_in(branch_target),
        .alu_result_in(alu_result),
        .write_data_in(forward_data2),
        .rd_in(rd_ex),
        .zero_in(zero),
        .RegWrite_out(RegWrite_mem),
        .MemToReg_out(MemToReg_mem),
        .MemRead_out(MemRead_mem),
        .MemWrite_out(MemWrite_mem),
        .Branch_out(Branch_mem),
        .Jump_out(Jump_mem),
        .branch_target_out(branch_target_mem),
        .alu_result_out(alu_result_mem),
        .write_data_out(write_data_mem),
        .rd_out(rd_mem),
        .zero_out(zero_mem)
    );
    
    // Conectar sinais para forwarding
    assign ex_mem_alu_result = alu_result_mem;
    assign EX_MEM_RegWrite_wire = RegWrite_mem;
    assign EX_MEM_rd_wire = rd_mem;

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
    
    BranchControl branch_ctrl (
        .Branch(Branch_mem),
        .Jump(Jump_mem),
        .zero(zero_mem),
        .PCSrc(PCSrc),
        .IF_ID_Flush(IF_ID_Flush),
        .ID_EX_Flush(ID_EX_Flush)
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
        .RegWrite_out(RegWrite_wb),
        .MemToReg_out(MemToReg_wb_reg),
        .read_data_out(read_data_wb_reg),
        .alu_result_out(alu_result_wb),
        .rd_out(rd_wb)
    );

    // ============ WB STAGE ============
    mux wb_mux (
        .A(read_data_wb_reg),
        .B(alu_result_wb),
        .select(MemToReg_wb_reg),
        .result(write_data_wb)
    );

endmodule
