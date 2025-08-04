`include "risc-v.v"
`timescale 1ns/100ps

module debug2_testbench;
  reg reset;
  riscv UUT(.reset(reset));

  initial begin
    $dumpfile("debug2.vcd");
    $dumpvars(0, debug2_testbench);

    // Reset
    reset = 1;
    #20;
    reset = 0;

    // Inicializa memória de dados
    UUT.datamem.mem[0] = 8'h00;

    // Monitor detalhado
    $monitor("Time: %0t | PC: %h | PC+4: %h | PC+imm: %h | imm: %h | orJump: %b | NextPC: %h", 
             $time, UUT.instructionAddress, UUT.resAdderB, UUT.resAdderA, UUT.imm, UUT.orJump, UUT.nextPCPosition);

    #300;
    $finish;
  end
endmodule
