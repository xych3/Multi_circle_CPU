`timescale 1ns / 1ps
module ALU(
    input [3:0] ALUSel,             // operation select
    input [31:0] dataA,             // dataA
    input [31:0] dataB,             // dataB
    output reg [31:0] res           // result
    );

    integer sign;
    integer i;
    initial begin
        res <= 32'h0000_0000;
    end

    always @(dataA or dataB or ALUSel) begin
        case (ALUSel)
            4'b0000: res <= dataA + dataB;
            4'b0001: res <= dataA - dataB;
            4'b0010: res <= dataA ^ dataB;
            4'b0011: res <= dataA | dataB;
            4'b0100: res <= dataA & dataB;
            4'b0101: res <= dataA << dataB;         // shift left fixed 0
            4'b0110: res <= dataA << dataB[4:0];    // imm shift left fixed 0
            4'b0111: res <= dataA >> dataB;         // shift right fixed 0
            4'b1000: res <= dataA >> dataB[4:0];    // imm shift right fixed 0
            4'b1001: begin                          // shift right fixed sign
                sign = dataA[31];
                res = dataA;
                for(i = 0; i<dataB[7:0]; i=i+1) begin
                    res = res >> 1;
                    res[31] = sign;
                end
            end
            4'b1010: begin                          // imm shift right fixed sign
                sign = dataA[31];
                res = dataA;
                for(i = 0; i<dataB[4:0]; i=i+1) begin
                    res = res >> 1;
                    res[31] = sign;
                end
            end
            4'b1011: res <= 32'h0000_0001;          // compare res 1
            4'b1100: res <= 32'h0000_0000;          // compare res 0
            4'b1101: res <= dataB << 12;            // imm << 12
            4'b1110: res <= dataA + (dataB<<12);    // PC+(imm<<12)
        endcase
    end
endmodule
