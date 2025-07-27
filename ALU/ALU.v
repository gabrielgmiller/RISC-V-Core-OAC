`include "ALU/operations/and.v"
`include "ALU/operations/sub.v"
`include "ALU/operations/sum.v"
`include "ALU/operations/or.v"
`include "ALU/operations/srl.v"

module ALU (
    input  [31:0] A,
    input  [31:0] B,
    input  [3:0]  ALUOp,
    output [31:0] result,
    output        zero
);
    wire [31:0] resAdd, resSub, resAnd, resOr, resSrl;

    sumALU    adder    (.A(A), .B(B), .result(resAdd), .Cout());
    sub       subtract(.A(A), .B(B), .result(resSub), .Cout());
    andModule andmod   (.A(A), .B(B), .result(resAnd));
    orModule  ormod    (.A(A), .B(B), .result(resOr));
    srlModule srlmod   (.A(A), .B(B), .result(resSrl));

    genvar i;
    generate
      for (i = 0; i < 32; i = i + 1) begin : MUX_BIT
        wire sel_add = (~ALUOp[3]&~ALUOp[2]& ALUOp[1]&~ALUOp[0]); // 0010
        wire sel_sub = (~ALUOp[3]& ALUOp[2]& ALUOp[1]&~ALUOp[0]); // 0110
        wire sel_and = (~ALUOp[3]&~ALUOp[2]&~ALUOp[1]&~ALUOp[0]); // 0000
        wire sel_or  = (~ALUOp[3]&~ALUOp[2]&~ALUOp[1]& ALUOp[0]); // 0001
        wire sel_srl = ( ALUOp[3]&~ALUOp[2]& ALUOp[1]&~ALUOp[0]); // 1010

        or(result[i],
           (resAdd[i] & sel_add),
           (resSub[i] & sel_sub),
           (resAnd[i] & sel_and),
           (resOr[i]  & sel_or),
           (resSrl[i] & sel_srl)
        );
      end
    endgenerate

    assign zero = ~|result;
endmodule