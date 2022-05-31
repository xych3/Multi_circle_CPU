`timescale 1ns / 1ps
module ASel(
    input asel,             // select control
    input [31:0] dataA,     // dataA
    input [31:0] dataB,     // dataB
    output reg [31:0] res   // result
    );
    always @(asel or dataB or dataA) begin
        if(asel==0) res <= dataA;
        else res <= dataB;
    end
endmodule
