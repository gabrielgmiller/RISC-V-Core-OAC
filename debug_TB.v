`include "risc-v.v"
`timescale 1ns/100ps

module debug_testbench;
  reg reset;
  riscv UUT(.reset(reset));

  initial begin
    $dumpfile("debug.vcd");
    $dumpvars(0, debug_testbench);

    // Reset
    reset = 1;
    #20;
    reset = 0;

    // Inicializa memória de dados
    UUT.datamem.mem[0] = 8'h00;

    // Monitor detalhado
    $monitor("Time: %0t | CLK: %b | PC: %h | NextPC: %h | Inst: %h | Branch: %b | Jump: %b | Zero: %b | AndBranch: %b | OrJump: %b", 
             $time, UUT.clk, UUT.instructionAddress, UUT.nextPCPosition, UUT.instructionCurrent, 
             UUT.Branch, UUT.Jump, UUT.zero, UUT.andBranch, UUT.orJump);

    #500;
    $finish;
  end
endmodule
