`include "risc-v_pipeline.v"
`timescale 1ns/100ps

module debug_pipeline_testbench;
  reg reset;
  riscv_pipeline UUT(.reset(reset));

  initial begin
    $dumpfile("debug_pipeline.vcd");
    $dumpvars(0, debug_pipeline_testbench);

    // Reset
    reset = 1;
    #20;
    reset = 0;

    // Inicializa memória de dados
    UUT.data_mem.mem[0] = 8'h00;

    // Debug básico
    #100;
    $display("PC: %h, Instruction: %h", UUT.pc_current, UUT.instruction_if);
    
    #100;
    $display("PC: %h, Instruction: %h", UUT.pc_current, UUT.instruction_if);
    
    #100;
    $display("PC: %h, Instruction: %h", UUT.pc_current, UUT.instruction_if);

    $finish;
  end
endmodule
