// ALU/operations/or.v
module orModule (
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] result
);
    genvar i;
    generate
      for (i = 0; i < 32; i = i + 1) begin
        or (result[i], A[i], B[i]);
      end
    endgenerate
endmodule