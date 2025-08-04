`include "risc-v.v"
`timescale 1ns/100ps

module final_testbench;
  integer i;
  reg reset;

  // Top‐level
  riscv UUT(.reset(reset));

  initial begin
    $dumpfile("final.vcd");
    $dumpvars(0, final_testbench);

    // --- Reset inicial por 2 ciclos (~40 ns) ---
    reset = 1;
    #20;
    reset = 0;

    // --- Inicializa DataMemory ---
    for (i = 0; i < 128; i = i + 1) begin
        UUT.datamem.mem[i] = 8'h00;
    end

    // Aguarda execução completa
    #3000;

    // === Verificação final ===
    $display("\n=== RESULTADO FINAL ===");
    $display("PC atual:      %h", UUT.instructionAddress);
    $display("x1  (addi):    %h (esperado: 00000007) %s", UUT.regs.register1, (UUT.regs.register1 == 32'h7) ? "✓" : "✗");
    $display("x2  (lb):      %h (esperado: 00000007) %s", UUT.regs.register2, (UUT.regs.register2 == 32'h7) ? "✓" : "✗");
    $display("x3  (sub):     %h (esperado: 00000000) %s", UUT.regs.register3, (UUT.regs.register3 == 32'h0) ? "✓" : "✗");
    $display("x4  (and):     %h (esperado: 00000007) %s", UUT.regs.register4, (UUT.regs.register4 == 32'h7) ? "✓" : "✗");
    $display("x5  (ori):     %h (esperado: 00000001) %s", UUT.regs.register5, (UUT.regs.register5 == 32'h1) ? "✓" : "✗");
    $display("x6  (srl):     %h (esperado: 00000001) %s", UUT.regs.register6, (UUT.regs.register6 == 32'h1) ? "✓" : "✗");
    $display("Mem[0] (sb):   %h (esperado: 07) %s", UUT.datamem.mem[0], (UUT.datamem.mem[0] == 8'h7) ? "✓" : "✗");

    // Contagem de sucessos
    i = 0;
    if (UUT.regs.register1 == 32'h7) i = i + 1;
    if (UUT.regs.register2 == 32'h7) i = i + 1;
    if (UUT.regs.register3 == 32'h0) i = i + 1;
    if (UUT.regs.register4 == 32'h7) i = i + 1;
    if (UUT.regs.register5 == 32'h1) i = i + 1;
    if (UUT.regs.register6 == 32'h1) i = i + 1;
    if (UUT.datamem.mem[0] == 8'h7) i = i + 1;
    
    $display("\nResultado: %0d/7 testes passaram", i);
    if (i == 7) $display("🎉 PROCESSADOR FUNCIONANDO PERFEITAMENTE!");
    else $display("❌ Ainda há problemas a corrigir");

    $finish;
  end
endmodule
