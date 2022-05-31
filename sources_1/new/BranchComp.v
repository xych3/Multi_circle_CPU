`timescale 1ns / 1ps
module BranchComp(
    input [1:0] brSel,      // 00-signed,01-unsigned,10-signed rs1/imm,11-unsigned rs1/imm
    input [31:0] rs1,       // rs1 data
    input [31:0] rs2,       // rs2 data
    input [31:0] imm,       // immediate number
    output reg brEq,        // 1 if dataA=dataB, else 0
    output reg brLt         // 1 if dataA>dataB, else 0
    );

    reg [31:0] dataA;
    reg [31:0] dataB;

    always @(brSel or rs1 or rs2) begin
        case (brSel)
            2'b10,
            2'b11: begin
                dataA <= rs1;
                dataB <= imm;
            end
            default: begin // 2'b00,2'b01
                dataA <= rs1;
                dataB <= rs2;
            end
        endcase
    end

    always @(brSel or dataA or dataB) begin
        case (brSel)
            2'b00,
            2'b10: begin
                if(dataA[31]==1 && dataB[31]==0) begin
                    brLt <= 0;
                    brEq <= 0;
                end
                else if(dataA[31]==0 && dataB[31]==1) begin
                    brLt <= 1;
                    brEq <= 0;
                end
                else if(dataA[31]==0 && dataB[31]==0) begin
                    brLt <= (dataA>dataB)? 1:0;
                    brEq <= (dataA==dataB)? 1:0;
                end
                else if(dataA[31]==1 && dataB[31]==1) begin
                    brLt <= (dataA<dataB)? 1:0;
                    brEq <= (dataA==dataB)? 1:0;
                end
            end
            2'b01,
            2'b11: begin
                brLt <= (dataA>dataB)? 1:0;
                brEq <= (dataA==dataB)? 1:0;
            end
        endcase
    end
endmodule
