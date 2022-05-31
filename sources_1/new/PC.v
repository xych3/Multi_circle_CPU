`timescale 1ns / 1ps
module PC(
    input clk,                      // clock
    input reset,                    // reset pc to 0
    input PCWre,                    // pc change select
    input [31:0] next_pc,           // next pc
    output reg[31:0] pc             // this pc
    );
    initial begin
        pc <= 32'h0000_0000;
    end
    always @(negedge clk or posedge reset) begin
        if(reset)
            pc <= 32'h0000_0000;
        else
            if(PCWre) pc <= next_pc;
    end
endmodule
