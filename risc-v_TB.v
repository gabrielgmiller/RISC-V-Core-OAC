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

    // imprime registradores x0–x7 (você pode expandir até x31)
    integer i;
    for (i = 0; i < 8; i = i + 1)
      $display("x%0d = %h", i, UUT.regs.regs[i]);

    // imprime memória de dados mem[0..7]
    for (i = 0; i < 8; i = i + 1)
      $display("mem[%0d] = %h", i, UUT.datamem.mem[i]);

    $finish;
  end

endmodule