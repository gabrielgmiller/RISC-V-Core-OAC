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

        // exemplo de inicialização manual seguindo seu mapa antigo:
        // Memory[0] = 9  → bytes [0..3] formam 0x00000009
        mem[0] = 8'h00; mem[1] = 8'h00; mem[2] = 8'h00; mem[3] = 8'h09;
        // Memory[1] = 10 → bytes [4..7] formam 0x0000000A
        mem[4] = 8'h00; mem[5] = 8'h00; mem[6] = 8'h00; mem[7] = 8'h0A;
        // … e assim por diante para Memory[2]..Memory[12]
        // Se ficar muito verboso, use:
        //    $readmemh("data_mem_init.mem", mem);
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