`timescale 1ns/100ps

module testbench ();
    reg  [31:0] A;
    reg  [31:0] B;
    reg  [3:0]  ALUOp;
    wire [31:0] result;
    wire        zero;

    ALU UUT (.A(A), .B(B), .ALUOp(ALUOp), .result(result), .zero(zero));

    integer errors = 0;
    task Check(input [31:0] expect);
      if (result !== expect) begin
        $display("Error: A=%0d B=%0d ALUOp=%b → expect=%0d got=%0d",
                 A, B, ALUOp, expect, result);
        errors = errors + 1;
      end
    endtask

    initial begin
      // Testes
      A = 10; B = 10; ALUOp = 4'b0010; #10; Check(20);
      A = 30; B = 10; ALUOp = 4'b0010; #10; Check(40);
      A = 30; B = 10; ALUOp = 4'b0110; #10; Check(20);
      A = 32'h3FFFC; B = 7;    ALUOp = 4'b0000; #10; Check(32'h3FFF4);
      A = 32'h3FFFC; B = 7;    ALUOp = 4'b0001; #10; Check(32'h3FFFF);
      $display("Test finished. Errors = %0d", errors);
      $finish;
    end
endmodule