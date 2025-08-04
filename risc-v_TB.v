`include "risc-v.v"
`timescale 1ns/100ps

module testbench;
  integer i;
  reg reset;

  // Top‐level
  riscv UUT(.reset(reset));

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, testbench);

    // --- Reset inicial por 2 ciclos (~40 ns) ---
    reset = 1;
    #20;
    reset = 0;

    // --- Inicializa DataMemory (não toca na InstructionMemory, ela carrega do .hex) ---
    // Inicializa memória de dados com zeros
    for (i = 0; i < 128; i = i + 1) begin
        UUT.datamem.mem[i] = 8'h00;
    end

    // pronto, o clock interno já está rodando...
  end

  // Monitor para debug
  initial begin
    $monitor("Time: %0t | PC: %h | Instruction: %h | RegWrite: %b | WriteReg: %d | WriteData: %h", 
             $time, UUT.instructionAddress, UUT.instructionCurrent, UUT.RegWrite, 
             UUT.instructionCurrent[11:7], UUT.dataToWrite);
  end

  initial begin
    // deixe rodar mais tempo
    #2000;

    // === Verificação dos valores esperados ===
    $display("\n=== Verificação dos valores esperados (baseado no programa assembly) ===");
    $display("PC atual:      %h", UUT.instructionAddress);
    $display("x1  (addi):    %h (esperado: 00000007)", UUT.regs.register1);
    $display("x2  (lb):      %h (esperado: 00000007)", UUT.regs.register2);
    $display("x3  (sub):     %h (esperado: 00000000)", UUT.regs.register3);
    $display("x4  (and):     %h (esperado: 00000007)", UUT.regs.register4);
    $display("x5  (ori):     %h (esperado: 00000001)", UUT.regs.register5);
    $display("x6  (srl):     %h (esperado: 00000001)", UUT.regs.register6);
    $display("Mem[0] (sb):   %h (esperado: 07)", UUT.datamem.mem[0]);

    // === Estado completo dos registradores ===
    $display("\n=== Estado dos registradores ===");
    $display("x0 : %h", UUT.regs.register0);
    $display("x1 : %h", UUT.regs.register1);
    $display("x2 : %h", UUT.regs.register2);
    $display("x3 : %h", UUT.regs.register3);
    $display("x4 : %h", UUT.regs.register4);
    $display("x5 : %h", UUT.regs.register5);
    $display("x6 : %h", UUT.regs.register6);
    $display("x7 : %h", UUT.regs.register7);
    $display("x8 : %h", UUT.regs.register8);
    $display("x9 : %h", UUT.regs.register9);
    $display("x10: %h", UUT.regs.register10);

    // === Primeiras 8 posições da memória de dados (bytes) ===
    $display("\n=== Primeiras 8 posições da memória de dados (bytes) ===");
    for (i = 0; i < 8; i = i + 1)
      $display("mem[%0d]: %h", i, UUT.datamem.mem[i]);

    // === Debug das instruções carregadas ===
    $display("\n=== Instruções carregadas da memória ===");
    for (i = 0; i < 10; i = i + 1)
      $display("inst[%0d]: %h", i, UUT.instmemo.mem[i]);

    $finish;
  end
endmodule
