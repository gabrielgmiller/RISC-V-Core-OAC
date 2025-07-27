`timescale 1ns/100ps

module InstructionMemory(
    input  [31:0] PC,
    output [31:0] instruction
);
    // 128 instruções de 32 bits
    reg [31:0] mem [0:127];
    integer i;

    initial begin
        // 1) Zera toda a ROM
        for (i = 0; i < 128; i = i + 1)
            mem[i] = 32'b0;
        // 2) Carrega o .hex com todas as instruções (uma por linha, em hex sem 0x)
        $readmemh("teste_grupo4.hex", mem);
    end

    // Saída: instrução na posição PC (em palavras)
    assign instruction = mem[PC];
endmodule