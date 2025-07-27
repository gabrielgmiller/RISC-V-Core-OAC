`timescale 1ns/100ps

module testbench();
  // sinal de reset
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
    // 4) carrega instruções
    $readmemh("teste_grupo4.hex",UUT.instmemo.mem);

    // 5) aplica reset ativo por 2 ciclos (~40 ns se seu clock for 20 ns de período)
    reset = 1'b1;
    #20;
    reset = 1'b0;
  end

  // relógio interno já gerado pelo ClockGen do DUT

  // controla duração da simulação e exibe resultados
  initial begin
    // espere tempo suficiente para executar todas as instruções
    #500;

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
    $display("x0 : %h", UUT.regs.regs[0]);
    $display("x1 : %h", UUT.regs.regs[1]);
    $display("x2 : %h", UUT.regs.regs[2]);
    $display("x3 : %h", UUT.regs.regs[3]);
    $display("x4 : %h", UUT.regs.regs[4]);
    $display("x5 : %h", UUT.regs.regs[5]);
    $display("x6 : %h", UUT.regs.regs[6]);
    $display("x7 : %h", UUT.regs.regs[7]);
    $display("x8 : %h", UUT.regs.regs[8]);
    $display("x9 : %h", UUT.regs.regs[9]);
    $display("x10: %h", UUT.regs.regs[10]);
    $display("x11: %h", UUT.regs.regs[11]);
    $display("x12: %h", UUT.regs.regs[12]);
    $display("x13: %h", UUT.regs.regs[13]);
    $display("x14: %h", UUT.regs.regs[14]);
    $display("x15: %h", UUT.regs.regs[15]);
    $display("x16: %h", UUT.regs.regs[16]);
    $display("x17: %h", UUT.regs.regs[17]);
    $display("x18: %h", UUT.regs.regs[18]);
    $display("x19: %h", UUT.regs.regs[19]);
    $display("x20: %h", UUT.regs.regs[20]);
    $display("x21: %h", UUT.regs.regs[21]);
    $display("x22: %h", UUT.regs.regs[22]);
    $display("x23: %h", UUT.regs.regs[23]);
    $display("x24: %h", UUT.regs.regs[24]);
    $display("x25: %h", UUT.regs.regs[25]);
    $display("x26: %h", UUT.regs.regs[26]);
    $display("x27: %h", UUT.regs.regs[27]);
    $display("x28: %h", UUT.regs.regs[28]);
    $display("x29: %h", UUT.regs.regs[29]);
    $display("x30: %h", UUT.regs.regs[30]);
    $display("x31: %h\n", UUT.regs.regs[31]);

    // === Primeiras 32 posições da memória de dados ===
    $display("=== Primeiras 32 posições da memória de dados ===");
    integer i;
    for (i = 0; i < 32; i = i + 1) begin
      $display("Mem[%0d]: %h", i, UUT.datamem.mem[i]);
    end

    $finish;
  end

endmodule