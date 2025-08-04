module data_memory(
    input         clk,         // relógio
    input         mem_read,    // ativa LB
    input         mem_write,   // ativa SB
    input  [31:0] endereco,    // endereço em bytes
    input  [31:0] write_data,  // dado de 32 bits (mas só o byte baixo é usado em SB)
    output reg [31:0] read_data // dado de 32 bits lido (sign-extend em LB)
);

    // 32 palavras × 4 bytes = 128 bytes totais
    // cada posição é um byte
    reg [7:0] mem [0:127];
    integer i;

    // inicialização (opcional: você pode usar $readmemh em vez disso)
    initial begin
        // zera tudo
        for (i = 0; i < 128; i = i + 1)
            mem[i] = 8'h00;
    end

    // escrita de byte: no flanco de subida do clock
    always @(posedge clk) begin
        if (mem_write) begin
            // armazena apenas o byte menos significativo
            mem[endereco] <= write_data[7:0];
        end
    end

    // leitura de byte + sign-extend: combinacional
    always @(*) begin
        if (mem_read) begin
            // replica o bit 7 do byte lido para os 24 bits superiores
            read_data = {{24{mem[endereco][7]}}, mem[endereco]};
        end else begin
            read_data = 32'b0;
        end
    end

endmodule