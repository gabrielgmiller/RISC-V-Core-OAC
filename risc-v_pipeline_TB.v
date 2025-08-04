`include "risc-v_pipeline.v"
`timescale 1ns/100ps

module pipeline_testbench;
  integer i, cycle_count;
  reg reset;

  // Top‐level
  riscv_pipeline UUT(.reset(reset));

  initial begin
    $dumpfile("pipeline_wave.vcd");
    $dumpvars(0, pipeline_testbench);

    cycle_count = 0;

    // --- Reset inicial ---
    reset = 1;
    #20;
    reset = 0;

    // --- Inicializa DataMemory ---
    for (i = 0; i < 128; i = i + 1) begin
        UUT.data_mem.mem[i] = 8'h00;
    end

    $display("=== INICIANDO SIMULAÇÃO DO PIPELINE ===");
    $display("Ciclo | PC     | IF_Inst | ID_Inst | EX_rd | MEM_rd | WB_rd | Stall | Flush");
    $display("------|--------|---------|---------|-------|--------|-------|-------|------");
  end

  // Monitor a cada ciclo de clock
  always @(posedge UUT.clk) begin
    cycle_count = cycle_count + 1;
    $display("%5d | %h | %h | %h | %5d | %6d | %5d | %5b | %5b", 
             cycle_count, UUT.pc_current, UUT.instruction_if, UUT.instruction_id,
             UUT.rd_ex, UUT.rd_mem, UUT.rd_wb, ~UUT.PCWrite, UUT.IF_ID_Flush);
    
    // Para após muitos ciclos para evitar loop infinito
    if (cycle_count > 50) begin
      $display("\n=== SIMULAÇÃO INTERROMPIDA APÓS 50 CICLOS ===");
      $finish;
    end
  end

  // Mostra estado dos registradores periodicamente
  always @(posedge UUT.clk) begin
    if (cycle_count % 10 == 0 && cycle_count > 0) begin
      $display("\n=== Ciclo %0d - Estado dos Registradores ===", cycle_count);
      $display("x1: %h | x2: %h | x3: %h | x4: %h | x5: %h | x6: %h", 
               UUT.reg_file.register1, UUT.reg_file.register2, UUT.reg_file.register3,
               UUT.reg_file.register4, UUT.reg_file.register5, UUT.reg_file.register6);
      $display("Mem[0]: %h | ForwardA: %b | ForwardB: %b", 
               UUT.data_mem.mem[0], UUT.ForwardA, UUT.ForwardB);
      $display("");
    end
  end

  initial begin
    // Aguarda execução completa
    #3000;

    // === Verificação final ===
    $display("\n=== RESULTADO FINAL DO PIPELINE ===");
    $display("Ciclos executados: %0d", cycle_count);
    $display("PC final: %h", UUT.pc_current);
    $display("");
    $display("x1  (addi):    %h (esperado: 00000007) %s", UUT.reg_file.register1, (UUT.reg_file.register1 == 32'h7) ? "✓" : "✗");
    $display("x2  (lb):      %h (esperado: 00000007) %s", UUT.reg_file.register2, (UUT.reg_file.register2 == 32'h7) ? "✓" : "✗");
    $display("x3  (sub):     %h (esperado: 00000000) %s", UUT.reg_file.register3, (UUT.reg_file.register3 == 32'h0) ? "✓" : "✗");
    $display("x4  (and):     %h (esperado: 00000007) %s", UUT.reg_file.register4, (UUT.reg_file.register4 == 32'h7) ? "✓" : "✗");
    $display("x5  (ori):     %h (esperado: 00000001) %s", UUT.reg_file.register5, (UUT.reg_file.register5 == 32'h1) ? "✓" : "✗");
    $display("x6  (srl):     %h (esperado: 00000001) %s", UUT.reg_file.register6, (UUT.reg_file.register6 == 32'h1) ? "✓" : "✗");
    $display("Mem[0] (sb):   %h (esperado: 07) %s", UUT.data_mem.mem[0], (UUT.data_mem.mem[0] == 8'h7) ? "✓" : "✗");

    // Contagem de sucessos
    i = 0;
    if (UUT.reg_file.register1 == 32'h7) i = i + 1;
    if (UUT.reg_file.register2 == 32'h7) i = i + 1;
    if (UUT.reg_file.register3 == 32'h0) i = i + 1;
    if (UUT.reg_file.register4 == 32'h7) i = i + 1;
    if (UUT.reg_file.register5 == 32'h1) i = i + 1;
    if (UUT.reg_file.register6 == 32'h1) i = i + 1;
    if (UUT.data_mem.mem[0] == 8'h7) i = i + 1;
    
    $display("\nResultado Pipeline: %0d/7 testes passaram", i);
    if (i == 7) $display("🎉 PROCESSADOR PIPELINE FUNCIONANDO PERFEITAMENTE!");
    else $display("❌ Pipeline ainda tem problemas - veja o debug acima");

    $finish;
  end
endmodule
