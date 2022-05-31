`timescale 1ns / 1ps
module DR(
    input clk,
    input [31:0] datain,
    output reg [31:0] dataout
    );
    initial begin
        dataout <= 0;
    end
    always @(posedge clk) begin
        dataout <= datain;
    end
endmodule
