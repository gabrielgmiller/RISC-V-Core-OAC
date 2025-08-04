`include "risc-v_pipeline_complete.v"
`timescale 1ns/100ps

module pipeline_complete_testbench;
  integer i, cycle_count;
  reg reset;

  // Top‐level
  riscv_pipeline_complete UUT(.reset(reset));

  initial begin
    $dumpfile("pipeline_complete_wave.vcd");
    $dumpvars(0, pipeline_complete_testbench);

    cycle_count = 0;

    // --- Reset inicial ---
    reset = 1;
    #20;
    reset = 0;

    // --- Inicializa DataMemory ---
    for (i = 0; i < 128; i = i + 1) begin
        UUT.data_mem.mem[i] = 8'h00;
    end

    $display("=== PIPELINE COMPLETO COM FORWARDING ===");
    $display("Ciclo | PC     | IF_Inst | ID_Inst | EX_rd | MEM_rd | WB_rd | FwdA | FwdB | Stall");
    $display("------|--------|---------|---------|-------|--------|-------|------|------|------");
  end

  // Monitor a cada ciclo de clock
  always @(posedge UUT.clk) begin
    cycle_count = cycle_count + 1;
    $display("%5d | %h | %h | %h | %5d | %6d | %5d | %4b | %4b | %5b", 
             cycle_count, UUT.pc_current, UUT.instruction_if, UUT.instruction_id,
             UUT.rd_ex, UUT.rd_mem, UUT.rd_wb, UUT.ForwardA, UUT.ForwardB, UUT.ControlMux);
    
    // Para após 20 ciclos e mostra resultados
    if (cycle_count == 20) begin
      $display("\n=== RESULTADO APÓS 20 CICLOS ===");
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
      
      $display("\nResultado Pipeline Completo: %0d/7 testes passaram", i);
      if (i == 7) $display("🎉 PROCESSADOR PIPELINE 100% FUNCIONAL!");
      else $display("❌ Pipeline ainda precisa de ajustes");
      
      $finish;
    end
  end

  initial begin
    // Aguarda execução completa
    #2500;
    $finish;
  end
endmodule
