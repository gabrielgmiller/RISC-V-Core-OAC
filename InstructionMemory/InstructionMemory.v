`timescale 1ns/100ps
module InstructionMemory(
    input  [31:0] PC,
    output [31:0] instruction
);
    // banco de 128 instruções de 32 bits
    reg [31:0] mem [0:127];

    initial begin
        // carregue exatamente o seu programa RISC-V já montado em hexadecimal
        $readmemh("teste_grupo4.hex", mem);
    end

    assign instruction = mem[PC];
endmodule