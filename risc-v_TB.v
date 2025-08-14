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
    $display("x11: %h", UUT.regs.register11);
    $display("x12: %h", UUT.regs.register12);
    $display("x13: %h", UUT.regs.register13);
    $display("x14: %h", UUT.regs.register14);
    $display("x15: %h", UUT.regs.register15);
    $display("x16: %h", UUT.regs.register16);
    $display("x17: %h", UUT.regs.register17);
    $display("x18: %h", UUT.regs.register18);
    $display("x19: %h", UUT.regs.register19);
    $display("x20: %h", UUT.regs.register20);
    $display("x21: %h", UUT.regs.register21);
    $display("x22: %h", UUT.regs.register22);
    $display("x23: %h", UUT.regs.register23);
    $display("x24: %h", UUT.regs.register24);
    $display("x25: %h", UUT.regs.register25);
    $display("x26: %h", UUT.regs.register26);
    $display("x27: %h", UUT.regs.register27);
    $display("x28: %h", UUT.regs.register28);
    $display("x29: %h", UUT.regs.register29);
    $display("x30: %h", UUT.regs.register30);
    $display("x31: %h", UUT.regs.register31);

    // === Primeiras 8 posições da memória de dados (bytes) ===
    $display("\n=== Primeiras 32 posições da memória de dados (bytes) ===");
    for (i = 0; i < 32; i = i + 1)
      $display("mem[%0d]: %h", i, UUT.datamem.mem[i]);

    // === Debug das instruções carregadas ===
    $display("\n=== Instruções carregadas da memória ===");
    for (i = 0; i < 10; i = i + 1)
      $display("inst[%0d]: %h", i, UUT.instmemo.mem[i]);

    $finish;
  end
endmodule
