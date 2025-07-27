module mux (
  input  [31:0] A,
  input  [31:0] B,
  input         select,
  output [31:0] result
);
  // operador ternário elimina o always/reg
  assign result = select ? A : B;
endmodule