// ALU/operations/sum.v
module sumALU (
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] result,
    output        Cout
);
    // Soma pura
    assign {Cout, result} = A + B;
endmodule