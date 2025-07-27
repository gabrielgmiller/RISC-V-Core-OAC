// ALU/operations/sub.v
module sub (
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] result,
    output        Cout
);
    // Subtração pura: Cout é borrow invertido (no RISC-V usamos Cout pra overflow)
    assign {Cout, result} = A - B;
endmodule