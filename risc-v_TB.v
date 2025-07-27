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

    // --- Carrega programa na InstructionMemory manualmente ---
    // lb   x5, 0(x0)      
    UUT.instmemo.mem[0] = 32'h00000283;
    // sb   x5, 4(x0)      
    UUT.instmemo.mem[1] = 32'h00500223;
    // sub  x6, x2, x1     
    UUT.instmemo.mem[2] = 32'h401101B3;
    // and  x7, x2, x1     
    UUT.instmemo.mem[3] = 32'h01172333;
    // ori  x8, x3, 1      
    UUT.instmemo.mem[4] = 32'h0011E293;
    // srl  x9, x5, x0     
    UUT.instmemo.mem[5] = 32'h002D3333;
    // beq  x6, x5, +4     
    UUT.instmemo.mem[6] = 32'h00530263;
    // instrução “errada” (NOP em RISC-V = addi x0,x0,0)
    UUT.instmemo.mem[7] = 32'h00000013;
    // preencha o resto com NOP
    for (i = 8; i < 32; i = i + 1)
      UUT.instmemo.mem[i] = 32'h00000013;

    // --- Inicializa DataMemory e registradores ---
    UUT.datamem.mem[0]  = 8'h07;          // dado para o lb
    // deixe o byte 4 limpo (será escrito pelo sb)
    UUT.datamem.mem[4]  = 8'h00;          
    // zere x1 e x2 (são usados no sub/and)
    UUT.regs.register1  = 32'h00000000;  
    UUT.regs.register2  = 32'h00000000;  
    // x3 será usado pelo ORI
    UUT.regs.register3  = 32'h00000000;
    // x10 não é usado nesse programa, pode ignorar

    // pronto, o clock interno já está rodando...
  end

  initial begin
    // deixe rodar tudo
    #500;

    // === Verificação dos valores esperados ===
    $display("\n=== Verificação dos valores esperados ===");
    $display("x5  (lb):      %h (esperado: 07)",       UUT.regs.register5);
    $display("x6  (sub):     %h (esperado: 00)",       UUT.regs.register6);
    $display("x7  (and):     %h (esperado: 00)",       UUT.regs.register7);
    $display("x8  (ori):     %h (esperado: 00000001)", UUT.regs.register8);
    $display("x9  (srl):     %h (esperado: 00000000)", UUT.regs.register9);
    $display("Mem[4] (sb):   %h (esperado: 07)\n",     UUT.datamem.mem[4]);

    // === Estado completo dos registradores ===
    $display("=== Estado dos registradores ===");
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
    // … e assim por diante até x31, se quiser

    // === Primeiras 32 posições da memória de dados (bytes) ===
    $display("\n=== Primeiras 32 posições da memória de dados (bytes) ===");
    for (i = 0; i < 8; i = i + 1)
      $display("mem[%0d]: %h", i, UUT.datamem.mem[i]);

    $finish;
  end
endmodule