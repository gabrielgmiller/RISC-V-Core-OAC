`include "risc-v.v"
`timescale 1ns/100ps

module debug_read_testbench;
  reg reset;
  riscv UUT(.reset(reset));

  initial begin
    $dumpfile("debug_read.vcd");
    $dumpvars(0, debug_read_testbench);

    // Reset
    reset = 1;
    #20;
    reset = 0;

    // Inicializa memória de dados
    UUT.datamem.mem[0] = 8'h00;

    // Monitor específico para leitura de registradores
    $monitor("Time: %0t | PC: %h | Inst: %h | rs1: %d | rs2: %d | ReadData1: %h | ReadData2: %h | ALUResult: %h", 
             $time, UUT.instructionAddress, UUT.instructionCurrent, 
             UUT.instructionCurrent[19:15], UUT.instructionCurrent[24:20],
             UUT.dataReadRegister1, UUT.dataReadRegister2, UUT.ALUResult);

    #1000;
    $finish;
  end
endmodule
