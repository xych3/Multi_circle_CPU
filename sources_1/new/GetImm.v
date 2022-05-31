`timescale 1ns / 1ps
module GetImm(
    input ExtSel,                   // zero-extends/msb-extend
    input [31:0] inst,              // instruction
    output reg [31:0] imm           // immediate number
    );

    initial begin
        imm <= 32'h0000_0000;
    end

    always @(inst) begin
        case (inst[6:0])
            7'b0010_011,
            7'b0000_011: 
            begin
                imm[11:0] <= inst[31:20];
                if (ExtSel && inst[31]==1) imm[31:12] <= 20'hfffff;
                else imm[31:12] <= 20'h00000;
            end
            7'b0100_011: 
            begin
                imm[4:0] <= inst[11:7];
                imm[11:5] <= inst[31:25];
                if (ExtSel && inst[31]==1) imm[31:12] <= 20'hfffff;
                else imm[31:12] <= 20'h00000;
            end
            7'b1100_011: 
            begin
                imm[0] <= 0;
                imm[11] <= inst[7];
                imm[4:1] <= inst[11:8];
                imm[10:5] <= inst[30:25];
                imm[12] <= inst[31];
                if (ExtSel && inst[31]==1) imm[31:12] <= 20'hfffff;
                else imm[31:12] <= 20'h00000;
            end
            7'b0110_111,
            7'b0010_111:
            begin
                imm[19:0] <= inst[31:12];
            end
            7'b1101_111: 
            begin
                imm[0] <= 0;
                imm[19:12] <= inst[19:12];
                imm[11] <= inst[20];
                imm[10:1] <= inst[30:21];
                imm[20] <= inst[31];
                if (ExtSel && inst[31]==1) imm[31:20] <= 12'hfff;
                else imm[31:20] <= 12'h000;
            end
            default imm <= 32'h0000_0000;
        endcase
    end
endmodule
