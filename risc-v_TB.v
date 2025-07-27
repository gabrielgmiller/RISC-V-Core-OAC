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

    // (Opcional) inicializa DataMemory, caso você tenha um data.mem
    // $readmemh("data.mem", UUT.datamem.mem);

    // Aplica reset por 2 ciclos
    reset = 1;
    #20;
    reset = 0;
  end

  initial begin
    // deixa rodar o programa
    #500;

    $display("\n=== Verificação dos valores esperados ===");
    $display("x5  (lb):      %h (esperado: 07)",       UUT.regs.register5);
    $display("x6  (addi/sub):%h (esperado: 00)",       UUT.regs.register6);
    $display("x7  (and):     %h (esperado: 00)",       UUT.regs.register7);
    $display("x8  (ori):     %h (esperado: 0000F0F0)", UUT.regs.register8);
    $display("x9  (srl):     %h (esperado: 00000003)", UUT.regs.register9);
    $display("Mem[4] (sb):   %h (esperado: 0F)\n",     UUT.datamem.mem[4]);

    $display("=== Estado completo dos registradores ===");
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

    $display("\n=== Primeiras 32 posições da memória de dados (bytes) ===");
    for (i = 0; i < 32; i = i + 1)
      $display("mem[%0d]: %h", i, UUT.datamem.mem[i]);

    $finish;
  end
endmodule