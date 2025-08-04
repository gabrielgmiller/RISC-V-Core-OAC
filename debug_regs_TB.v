`include "risc-v.v"
`timescale 1ns/100ps

module debug_regs_testbench;
  reg reset;
  riscv UUT(.reset(reset));

  initial begin
    $dumpfile("debug_regs.vcd");
    $dumpvars(0, debug_regs_testbench);

    // Reset
    reset = 1;
    #20;
    reset = 0;

    // Inicializa memória de dados
    UUT.datamem.mem[0] = 8'h00;
  end

  // Monitor a cada borda de clock
  always @(posedge UUT.clk) begin
    $display("Ciclo %0t | PC: %h | Inst: %h | x1: %h | x2: %h | x3: %h | x4: %h | x5: %h | x6: %h", 
             $time, UUT.instructionAddress, UUT.instructionCurrent, 
             UUT.regs.register1, UUT.regs.register2, UUT.regs.register3, 
             UUT.regs.register4, UUT.regs.register5, UUT.regs.register6);
  end

  initial begin
    #1000;
    $finish;
  end
endmodule
