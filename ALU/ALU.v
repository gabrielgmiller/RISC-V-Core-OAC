`include "./operations/and.v"
`include "./operations/sub.v"
`include "./operations/sum.v"
`include "./operations/or.v"
`include "./operations/srl.v"

module ALU (
    input  [31:0] A,
    input  [31:0] B,
    input  [3:0]  ALUOp,
    output [31:0] result,
    output        zero
);
    // resultados das operações
    wire [31:0] resAdd, resSub, resAnd, resOr, resSrl;

    // instâncias
    sumALU    adder    (.A(A), .B(B), .result(resAdd), .Cout());
    sub       subtract(.A(A), .B(B), .result(resSub), .Cout());
    andModule andmod   (.A(A), .B(B), .result(resAnd));
    orModule  ormod    (.A(A), .B(B), .result(resOr));
    srl       srlmod   (.A(A), .B(B), .result(resSrl));

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : MUX_BIT
            // seletor de cada operação para o bit i
            wire sel_add, sel_sub, sel_and, sel_or, sel_srl;

            and(sel_add, resAdd[i], ~ALUOp[3], ~ALUOp[2],  ALUOp[1], ~ALUOp[0]); // 0010
            and(sel_sub, resSub[i], ~ALUOp[3],  ALUOp[2],  ALUOp[1], ~ALUOp[0]); // 0110
            and(sel_and, resAnd[i], ~ALUOp[3], ~ALUOp[2], ~ALUOp[1], ~ALUOp[0]); // 0000
            and(sel_or,  resOr[i],  ~ALUOp[3], ~ALUOp[2], ~ALUOp[1],  ALUOp[0]); // 0001
            and(sel_srl,resSrl[i],  ALUOp[3], ~ALUOp[2],  ALUOp[1], ~ALUOp[0]); // 1001

            or(result[i],
               sel_add,
               sel_sub,
               sel_and,
               sel_or,
               sel_srl
            );
        end
    endgenerate

    // zero = NOR de todos os bits
    assign zero = ~|result;

endmodule