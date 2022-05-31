`timescale 1ns / 1ps
module IR(
    input clk,
    input IRWre,
    input [31:0] instdata,
    output reg [31:0] inst
    );
    initial begin
        inst <= 0;
    end
    always @(posedge clk) begin
        if(IRWre) inst <= instdata;
    end
endmodule
