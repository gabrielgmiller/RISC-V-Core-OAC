module immediateG(
    input  [31:0] instruction,
    output reg [31:0] immediate
);
    wire [6:0] opcode = instruction[6:0];
    wire [31:0] immI  = {{20{instruction[31]}}, instruction[31:20]};                     // I-type: addi, lb, ori
    wire [31:0] immS  = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};   // S-type: sb
    wire [31:0] immB  = {{19{instruction[31]}}, instruction[31], instruction[7],
                         instruction[30:25], instruction[11:8], 1'b0};                   // B-type: beq
    wire [31:0] immJ  = {{11{instruction[31]}}, instruction[31], instruction[19:12],
                         instruction[20], instruction[30:21], 1'b0};                     // J-type: j

    always @(*) begin
        case (opcode)
            7'b0000011, // LB (I-type)
            7'b0010011: // ADDI, ORI (I-type)
                immediate = immI;

            7'b0100011: // SB (S-type)
                immediate = immS;

            7'b1100011: // BEQ (B-type)
                immediate = immB;

            7'b1101111: // J (J-type)
                immediate = immJ;

            default:
                immediate = 32'd0;
        endcase
    end
endmodule