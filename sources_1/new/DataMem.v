`timescale 1ns / 1ps
module DataMem(
    input clk,                      // clock
    input reset,                    // clear all data
    input [2:0] memRW,              // read or write control
    input [31:0] addr,              // address
    input [31:0] dataW,             // data to write
    output reg [31:0] dataR         // read data output
    );

    reg [7:0] RAM[0:255];
    reg [31:0] target;
    reg sign;
    integer i;

    initial begin
        for (i = 0; i<256; i=i+1) begin
            RAM[i] <= 0;
        end
        dataR <= 32'h0000_0000;
        target <= 32'h0000_0000;
    end

    // read
    always @(*) begin
        target = {RAM[addr],RAM[addr+1],RAM[addr+2],RAM[addr+3]};
        case (memRW)
            3'b000: begin // lb
                sign = target[7];
                dataR = {{24{sign}}, target[7:0]};
            end
            3'b001: begin // lh
                sign = target[15];
                dataR = {{16{sign}}, target[15:0]};
            end
            3'b010: begin // lbu
                sign = 0;
                dataR = {{24{sign}}, target[7:0]};
            end
            3'b011: begin // lhu
                sign = 0;
                dataR = {{16{sign}}, target[15:0]};
            end
            3'b100: begin // lw - 31 bits read
                sign = target[31];
                dataR = target;
            end
        endcase
    end

    // write
    always @(negedge clk or negedge reset) begin
        if(reset) begin
            for (i = 0; i<256; i=i+1) begin
                RAM[i] <= 0;
            end
        end
        else begin
            case (memRW)
                3'b101: begin // sb
                    RAM[addr] <= dataW[7:0];
                end
                3'b110: begin // sh
                    {RAM[addr], RAM[addr+1]} <= dataW[15:0];
                end
                3'b111: begin // sw - 31 bits write
                    {RAM[addr],RAM[addr+1],RAM[addr+2],RAM[addr+3]} <= dataW;
                end
            endcase   
        end
    end
endmodule