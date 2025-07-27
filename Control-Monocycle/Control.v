`timescale 1ns/100ps

module control_tb;
  // --- Inputs da Unidade de Controle ---
  reg [6:0] Op;

  // --- Saídas observadas ---
  wire RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch;
  wire ALUOp1, ALUOp0;

  // Instancia a ControlUnit
  ControlUnit uut (
    .Op     (Op),
    .RegDst (RegDst),
    .ALUSrc (ALUSrc),
    .MemToReg(MemToReg),
    .RegWrite(RegWrite),
    .MemRead (MemRead),
    .MemWrite(MemWrite),
    .Branch  (Branch),
    .ALUOp1  (ALUOp1),
    .ALUOp0  (ALUOp0)
  );

  integer errors;
  task check_signals;
    input e_RegDst, e_ALUSrc, e_MemToReg, e_RegWrite, e_MemRead, e_MemWrite, e_Branch, e_ALUOp1, e_ALUOp0;
    begin
      if (
          RegDst    !== e_RegDst    ||
          ALUSrc    !== e_ALUSrc    ||
          MemToReg  !== e_MemToReg  ||
          RegWrite  !== e_RegWrite  ||
          MemRead   !== e_MemRead   ||
          MemWrite  !== e_MemWrite  ||
          Branch    !== e_Branch    ||
          ALUOp1    !== e_ALUOp1    ||
          ALUOp0    !== e_ALUOp0
         ) begin
        $display("  ERROR for Op=%b:", Op);
        $display("    got   RDst=%b ASrc=%b M2R=%b RW=%b MR=%b MW=%b Br=%b OP1=%b OP0=%b",
                 RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp1, ALUOp0);
        $display("    expect RDst=%b ASrc=%b M2R=%b RW=%b MR=%b MW=%b Br=%b OP1=%b OP0=%b\n",
                 e_RegDst, e_ALUSrc, e_MemToReg, e_RegWrite, e_MemRead, e_MemWrite, e_Branch, e_ALUOp1, e_ALUOp0);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    errors = 0;
    $display("\n--- Testando ControlUnit ---\n");

    // R-type (0110011)
    Op = 7'b0110011; #10;
    // RegDst=1, ALUSrc=0, MemToReg=0, RegWrite=1, MemRead=0, MemWrite=0, Branch=0, ALUOp1=1, ALUOp0=0
    check_signals(1,0,0,1,0,0,0,1,0);

    // LB (0000011)
    Op = 7'b0000011; #10;
    // RegDst=0, ALUSrc=1, MemToReg=1, RegWrite=1, MemRead=1, MemWrite=0, Branch=0, ALUOp1=0, ALUOp0=0
    check_signals(0,1,1,1,1,0,0,0,0);

    // SB (0100011)
    Op = 7'b0100011; #10;
    // RegDst=X, ALUSrc=1, MemToReg=X, RegWrite=0, MemRead=0, MemWrite=1, Branch=0, ALUOp1=0, ALUOp0=0
    check_signals(0,1,0,0,0,1,0,0,0);

    // BEQ (1100011)
    Op = 7'b1100011; #10;
    // RegDst=X, ALUSrc=0, MemToReg=X, RegWrite=0, MemRead=0, MemWrite=0, Branch=1, ALUOp1=0, ALUOp0=1
    check_signals(0,0,0,0,0,0,1,0,1);

    // ORI (0010011)
    Op = 7'b0010011; #10;
    // RegDst=0, ALUSrc=1, MemToReg=0, RegWrite=1, MemRead=0, MemWrite=0, Branch=0, ALUOp1=1, ALUOp0=1
    check_signals(0,1,0,1,0,0,0,1,1);

    $display("\nTest finished with %0d error(s)\n", errors);
    $finish;
  end

endmodule