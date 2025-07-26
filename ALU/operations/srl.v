module srl (
    input [31:0] A,     // Valor a ser deslocado
    input [31:0] B,     // Quantidade de bits para deslocar (apenas os 5 últimos bits de B são usados)
    output [31:0] result
);
    assign result = A >> B[4:0];  // Shift lógico à direita com 5 bits (0 a 31)
endmodule