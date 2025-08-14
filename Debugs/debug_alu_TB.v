`include "risc-v.v"
`timescale 1ns/100ps

module debug_alu_testbench;
  reg reset;
  riscv UUT(.reset(reset));

  initial begin
    $dumpfile("debug_alu.vcd");
    $dumpvars(0, debug_alu_testbench);

    // Reset
    reset = 1;
    #20;
    reset = 0;

    // Inicializa memória de dados
    UUT.datamem.mem[0] = 8'h00;

    // Monitor específico para ALU
    $monitor("Time: %0t | PC: %h | Inst: %h | ALUOp: %b | A: %h | B: %h | Result: %h | RegWrite: %b | WriteReg: %d", 
             $time, UUT.instructionAddress, UUT.instructionCurrent, UUT.ALUOp, 
             UUT.dataReadRegister1, UUT.ndInputALU, UUT.ALUResult, UUT.RegWrite, UUT.instructionCurrent[11:7]);

    #1000;
    $finish;
  end
endmodule
