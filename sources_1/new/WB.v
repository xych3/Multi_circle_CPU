`timescale 1ns / 1ps
module WB(
    input [1:0] WBSel,              // write byte select
    input [31:0] alu,               // alu result
    input [31:0] mem,               // data memory
    input [31:0] pc4,               // pc+4
    output reg [31:0] wb            // select output
    );
    initial begin
        wb <= 32'h0000_0000;
    end
    always @(*) begin
        case (WBSel)
            2'b00: wb <= mem;
            2'b01: wb <= alu;
            2'b10: wb <= pc4;
            default: wb <= 32'h0000_0000;
        endcase
    end
endmodule
