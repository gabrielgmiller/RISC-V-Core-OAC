`timescale 1ns/100ps
module PC (
  input  wire [31:0] datain,  // novos bits de endereço
  input  wire        enable,  // quando 1, aceita datain; senão, mantém PC
  input  wire        reset,   // reseta PC a zero
  input  wire        clk,
  output reg  [31:0] dataout  // valor atual de PC
);

  // valor inicial só para simulação
  initial dataout = 32'd0;

  // flip-flop de 32 bits com reset síncrono
  always @(posedge clk) begin
    if (reset)
      dataout <= 32'd0;
    else if (enable)
      dataout <= datain;
  end

endmodule