`include "risc-v.v"
`timescale 1ns/100ps

module debug_mem_testbench;
  reg reset;
  riscv UUT(.reset(reset));

  initial begin
    $dumpfile("debug_mem.vcd");
    $dumpvars(0, debug_mem_testbench);

    // Reset
    reset = 1;
    #20;
    reset = 0;

    // Inicializa memória de dados
    UUT.datamem.mem[0] = 8'h00;

    // Monitor específico para memória
    $monitor("Time: %0t | PC: %h | Inst: %h | MemWrite: %b | MemRead: %b | Addr: %h | WriteData: %h | ReadData: %h | Mem[0]: %h", 
             $time, UUT.instructionAddress, UUT.instructionCurrent, UUT.MemWrite, UUT.MemRead, 
             UUT.ALUResult, UUT.dataReadRegister2, UUT.dataReadFromMemory, UUT.datamem.mem[0]);

    #1000;
    $finish;
  end
endmodule
