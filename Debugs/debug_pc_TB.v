`include "risc-v_pipeline.v"
`timescale 1ns/100ps

module debug_pc_testbench;
  reg reset;
  riscv_pipeline UUT(.reset(reset));

  initial begin
    $dumpfile("debug_pc.vcd");
    $dumpvars(0, debug_pc_testbench);

    // Reset
    reset = 1;
    #20;
    reset = 0;

    // Debug específico do PC
    #10;
    $display("=== DEBUG DO PC ===");
    $display("PC atual: %h", UUT.pc_current);
    $display("PC+4: %h", UUT.pc_plus4);
    $display("PC next: %h", UUT.pc_next);
    $display("PCWrite: %b", UUT.PCWrite);
    $display("PCSrc: %b", UUT.PCSrc);
    $display("Reset: %b", reset);
    $display("Clock: %b", UUT.clk);
    
    #100;
    $display("\n=== APÓS 100ns ===");
    $display("PC atual: %h", UUT.pc_current);
    $display("PC+4: %h", UUT.pc_plus4);
    $display("PC next: %h", UUT.pc_next);
    $display("PCWrite: %b", UUT.PCWrite);
    $display("PCSrc: %b", UUT.PCSrc);
    
    #100;
    $display("\n=== APÓS 200ns ===");
    $display("PC atual: %h", UUT.pc_current);
    $display("PC+4: %h", UUT.pc_plus4);
    $display("PC next: %h", UUT.pc_next);
    $display("PCWrite: %b", UUT.PCWrite);
    $display("PCSrc: %b", UUT.PCSrc);

    $finish;
  end
endmodule
