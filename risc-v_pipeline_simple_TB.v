`include "risc-v_pipeline_simple.v"
`timescale 1ns/100ps

module pipeline_simple_testbench;
  integer i, cycle_count;
  reg reset;

  // Top‐level
  riscv_pipeline_simple UUT(.reset(reset));

  initial begin
    $dumpfile("pipeline_simple_wave.vcd");
    $dumpvars(0, pipeline_simple_testbench);

    cycle_count = 0;

    // --- Reset inicial ---
    reset = 1;
    #20;
    reset = 0;

    // --- Inicializa DataMemory ---
    for (i = 0; i < 128; i = i + 1) begin
        UUT.data_mem.mem[i] = 8'h00;
    end

    $display("=== PIPELINE SIMPLIFICADO ===");
    $display("Ciclo | PC     | IF_Inst | ID_Inst | EX_rd | MEM_rd | WB_rd");
    $display("------|--------|---------|---------|-------|--------|------");
  end

  // Monitor a cada ciclo de clock
  always @(posedge UUT.clk) begin
    cycle_count = cycle_count + 1;
    $display("%5d | %h | %h | %h | %5d | %6d | %5d", 
             cycle_count, UUT.pc_current, UUT.instruction_if, UUT.instruction_id,
             UUT.rd_ex, UUT.rd_mem, UUT.rd_wb_wire);
    
    // Para após 15 ciclos e mostra resultados
    if (cycle_count == 15) begin
      $display("\n=== RESULTADO APÓS 15 CICLOS ===");
      $display("x1: %h | x2: %h | x3: %h | x4: %h | x5: %h | x6: %h", 
               UUT.reg_file.register1, UUT.reg_file.register2, UUT.reg_file.register3,
               UUT.reg_file.register4, UUT.reg_file.register5, UUT.reg_file.register6);
      $display("Mem[0]: %h", UUT.data_mem.mem[0]);
      
      // Contagem de sucessos
      i = 0;
      if (UUT.reg_file.register1 == 32'h7) i = i + 1;
      if (UUT.reg_file.register2 == 32'h7) i = i + 1;
      if (UUT.reg_file.register3 == 32'h0) i = i + 1;
      if (UUT.reg_file.register4 == 32'h7) i = i + 1;
      if (UUT.reg_file.register5 == 32'h1) i = i + 1;
      if (UUT.reg_file.register6 == 32'h1) i = i + 1;
      if (UUT.data_mem.mem[0] == 8'h7) i = i + 1;
      
      $display("Resultado: %0d/7 testes passaram", i);
      if (i == 7) $display("🎉 PIPELINE SIMPLIFICADO FUNCIONANDO PERFEITAMENTE!");
      else $display("❌ Pipeline simplificado com problemas");
      
      $finish;
    end
  end

  initial begin
    // Aguarda execução completa
    #2500;
    $finish;
  end
endmodule
