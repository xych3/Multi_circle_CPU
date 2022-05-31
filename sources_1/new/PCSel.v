`timescale 1ns / 1ps
module PCSel(
    input stop,
    input PCSel,
    input [31:0] alu,
    input [31:0] pc4,
    output reg [31:0] next_pc
    );
    always @(*) begin
        if(stop) next_pc <= pc4;
        else next_pc = PCSel==1? pc4:alu;
    end
endmodule
