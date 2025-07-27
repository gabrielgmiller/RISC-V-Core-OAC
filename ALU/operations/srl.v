// ALU/operations/srl.v
module srlModule (
    input  [31:0] A,    // Valor a ser deslocado
    input  [31:0] B,    // Quantidade de bits para deslocar
    output [31:0] result
);
    assign result = A >> B[4:0];
endmodule