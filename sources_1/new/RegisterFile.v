`timescale 1ns / 1ps
module RegisterFile(
    input clk,                      // clock
    input reset,                    // clear all reg
    input wEn,                      // write enable
    input [4:0]addrD,               // rd address
    input [4:0]addrA,               // rs1 address
    input [4:0]addrB,               // rs2 address
    input [31:0]dataD,              // data to write
    output reg [31:0] dataA,        // read rs1 data
    output reg [31:0] dataB         // read rs2 data
    );

    reg [31:0] RegFile[0:31];       // Registers
    integer i;                      // initialization all registers

    initial begin
        for (i = 0; i<32; i=i+1) begin
            RegFile[i] <= 0;
        end
    end

    // write
    always @(negedge clk or negedge reset) begin
        if(reset) begin
            for (i = 0; i<32; i=i+1) begin
                RegFile[i] <= 0;
            end
        end
        else if(wEn) RegFile[addrD] <= dataD;
    end

    // read
    always @(*) begin
        dataA <= RegFile[addrA];
        dataB <= RegFile[addrB];
    end

endmodule
