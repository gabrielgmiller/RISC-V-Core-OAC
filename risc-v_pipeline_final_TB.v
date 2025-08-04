`include "risc-v_pipeline_simple.v"
`timescale 1ns/100ps

module pipeline_final_testbench;
  integer i, cycle_count;
  reg reset;
  riscv_pipeline_simple UUT(.reset(reset));

  initial begin
    $dumpfile("pipeline_final.vcd");
    $dumpvars(0, pipeline_final_testbench);
    cycle_count = 0;
    reset = 1; #20; reset = 0;
    
    for (i = 0; i < 128; i = i + 1) UUT.data_mem.mem[i] = 8'h00;
    $display("=== PIPELINE FINAL ===");
  end

  always @(posedge UUT.clk) begin
    cycle_count = cycle_count + 1;
    $display("Ciclo %2d | PC: %h | Inst: %h", cycle_count, UUT.pc_current, UUT.instruction_if);
    
    if (cycle_count == 30) begin
      $display("\n=== RESULTADOS FINAIS ===");
      $display("x1: %h (esperado: 7) %s", UUT.reg_file.register1, (UUT.reg_file.register1 == 32'h7) ? "✓" : "✗");
      $display("x2: %h (esperado: 7) %s", UUT.reg_file.register2, (UUT.reg_file.register2 == 32'h7) ? "✓" : "✗");
      $display("x3: %h (esperado: 0) %s", UUT.reg_file.register3, (UUT.reg_file.register3 == 32'h0) ? "✓" : "✗");
      $display("x4: %h (esperado: 7) %s", UUT.reg_file.register4, (UUT.reg_file.register4 == 32'h7) ? "✓" : "✗");
      $display("x5: %h (esperado: 1) %s", UUT.reg_file.register5, (UUT.reg_file.register5 == 32'h1) ? "✓" : "✗");
      $display("x6: %h (esperado: 1) %s", UUT.reg_file.register6, (UUT.reg_file.register6 == 32'h1) ? "✓" : "✗");
      $display("Mem[0]: %h (esperado: 7) %s", UUT.data_mem.mem[0], (UUT.data_mem.mem[0] == 8'h7) ? "✓" : "✗");
      
      i = 0;
      if (UUT.reg_file.register1 == 32'h7) i = i + 1;
      if (UUT.reg_file.register2 == 32'h7) i = i + 1;
      if (UUT.reg_file.register3 == 32'h0) i = i + 1;
      if (UUT.reg_file.register4 == 32'h7) i = i + 1;
      if (UUT.reg_file.register5 == 32'h1) i = i + 1;
      if (UUT.reg_file.register6 == 32'h1) i = i + 1;
      if (UUT.data_mem.mem[0] == 8'h7) i = i + 1;
      
      $display("\n🎯 RESULTADO: %0d/7 testes passaram", i);
      if (i >= 5) $display("🎉 PIPELINE FUNCIONANDO MUITO BEM!");
      else $display("⚠️ Pipeline parcialmente funcional");
      $finish;
    end
  end

  initial #2000 $finish;
endmodule
