`timescale 1ns/100ps

module testbench();
  integer i;
  reg reset;

  // instância do seu design
  riscv UUT (
    .reset(reset)
  );

  initial begin
    // 1) dump de waveform
    $dumpfile("wave.vcd");
    $dumpvars(0, testbench);

    // 2) carrega registradores (32 words de 32 bits)
    $readmemh("regs.mem",        UUT.regs.regs);
    // 3) carrega memória de dados (seu DataMemory tem mem[0..127])
    $readmemh("data.mem",        UUT.datamem.mem);
    // 4) carrega instruções (array chama-se Memory, não mem)
    $readmemh("teste_grupo4.hex", UUT.instmemo.Memory);

    // 5) aplica reset ativo por 2 ciclos (~40 ns se seu clock for 20 ns)
    reset = 1'b1;
    #20;
    reset = 1'b0;
  end

  // relógio interno já gerado pelo ClockGen do DUT

  initial begin
    #500;  // tempo suficiente para rodar tudo

    // === Verificação dos resultados ===
    $display("\n=== Verificação dos valores esperados ===");
    $display("x5  (lb):      %h (esperado: 07)",       UUT.regs.regs[5]);
    $display("x6  (addi/sub):%h (esperado: 00)",       UUT.regs.regs[6]);
    $display("x7  (and):     %h (esperado: 00)",       UUT.regs.regs[7]);
    $display("x8  (ori):     %h (esperado: 0000F0F0)", UUT.regs.regs[8]);
    $display("x9  (srl):     %h (esperado: 00000003)", UUT.regs.regs[9]);
    $display("Mem[4] (sb):   %h (esperado: 0F)\n",     UUT.datamem.mem[4]);

    // === Estado completo dos registradores ===
    $display("=== Estado dos registradores ===");
    for (i = 0; i < 32; i = i + 1)
      $display("x%0d: %h", i, UUT.regs.regs[i]);

    // === Primeiras 32 posições da memória de dados (bytes) ===
    $display("\n=== Primeiras 32 posições da memória de dados (bytes) ===");
    for (i = 0; i < 32; i = i + 1)
      $display("Mem[%0d]: %h", i, UUT.datamem.mem[i]);

    $finish;
  end

endmodule