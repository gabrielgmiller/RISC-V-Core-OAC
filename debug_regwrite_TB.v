`include "risc-v.v"
`timescale 1ns/100ps

module debug_regwrite_testbench;
  reg reset;
  riscv UUT(.reset(reset));

  initial begin
    $dumpfile("debug_regwrite.vcd");
    $dumpvars(0, debug_regwrite_testbench);

    // Reset
    reset = 1;
    #20;
    reset = 0;

    // Inicializa memória de dados
    UUT.datamem.mem[0] = 8'h00;

    // Monitor específico para RegWrite
    $monitor("Time: %0t | PC: %h | Inst: %h | Op: %b | RegWrite: %b | WriteReg: %d | WriteData: %h", 
             $time, UUT.instructionAddress, UUT.instructionCurrent, UUT.instructionCurrent[6:0],
             UUT.RegWrite, UUT.instructionCurrent[11:7], UUT.dataToWrite);

    #1000;
    $finish;
  end
endmodule
