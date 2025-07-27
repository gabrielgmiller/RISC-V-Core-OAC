// alu_control_tb.v
`timescale 1ns/100ps
module testbench();
    reg        ALUOp1;
    reg        ALUOp0;
    reg [3:0]  funct;
    wire [3:0] operation;

    integer errors;
    task Check(input [3:0] expect);
        if (operation !== expect) begin
            $display("Error: ALUOp=%b funct=%b → expect=%b got=%b",
                     {ALUOp1,ALUOp0}, funct, expect, operation);
            errors = errors + 1;
        end
    endtask

    ALU_Control uut (
      .ALUOp1(ALUOp1),
      .ALUOp0(ALUOp0),
      .funct (funct),
      .operation(operation)
    );

    initial begin
        errors = 0;

        // ALUOp = 00: I-type / loads / stores
        ALUOp1 = 0; ALUOp0 = 0;
        #5;
        for (funct = 0; funct < 16; funct = funct + 1) begin
            #5; Check(4'b0010);  // sempre ADDI/LW/SW → código 0010
        end

        // ALUOp = 01: Branch
        ALUOp1 = 0; ALUOp0 = 1;
        #5;
        for (funct = 0; funct < 16; funct = funct + 1) begin
            #5; Check(4'b0110);  // sempre SUB (BEQ) → código 0110
        end

        // ALUOp = 10: R-type
        ALUOp1 = 1; ALUOp0 = 0;
        #5;
        // testando todos os funct3/funct7 combos
        // funct = {f7[5], f3[2:0]}
        for (funct = 0; funct < 16; funct = funct + 1) begin
            #5;
            case (funct)
                4'b0000: Check(4'b0010); // ADD
                4'b1000: Check(4'b0110); // SUB
                4'b0111: Check(4'b0000); // AND
                4'b0110: Check(4'b0001); // OR
                4'b0101: Check(4'b0011); // SRL  (você pode ajustar código se for 0101)
                default: ;               // outros: não utilizados
            endcase
        end

        #5;
        $display("ALU_Control test finished — errors = %0d", errors);
        $finish;
    end
endmodule