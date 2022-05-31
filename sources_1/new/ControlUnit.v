`timescale 1ns / 1ps
module ControlUnit(
    input clk,
    input reset,
    input breq,
    input brlt,
    input [31:0] inst,
    output reg PCWre,
    output reg IRWre,
    output reg ExtSel,
    output reg insmemRW,
    output reg regwEn,
    output reg pcsel,
    output reg asel,
    output reg bsel,
    output reg [1:0] wbsel,
    output reg [1:0] brsel,
    output reg [2:0] datarw,
    output reg [3:0] alusel
    );

    reg [2:0] state;
    reg [2:0] next_state;
    parameter [2:0] IF = 3'b000,
                    ID = 3'b001,
                    EXE_010 = 3'b010,
                    WB_011 = 3'b011,
                    EXE_100 = 3'b100,
                    EXE_101 = 3'b101,
                    MEM_110 = 3'b110,
                    WB_111 = 3'b111;
    
    initial begin
        state <= IF;
        next_state <= ID;
        PCWre <= 0;
        IRWre <= 1;
        ExtSel <= 1;
        insmemRW <= 0;
        regwEn <= 0;
        pcsel <= 1;
        asel <= 1;
        bsel <= 0;
        wbsel <= 3;
        brsel <= 0;
        datarw <= 0;
        alusel <= 15;
    end

    always @(posedge clk) begin
        if(reset) state <= IF;
        else begin
            state <= next_state;
        end
    end

    // next_state
    always @(*) begin
        case (state)
            IF: next_state <= ID;
            ID: begin
                case (inst[6:0])
                    7'b011_0011,
                    7'b001_0011,
                    7'b110_1111,
                    7'b110_0111,
                    7'b011_0111,
                    7'b001_0111: next_state <= EXE_010;
                    7'b110_0011: next_state <= EXE_100;
                    7'b000_0011,
                    7'b010_0011: next_state <= EXE_101;
                    default: next_state <= IF;
                endcase
            end
            EXE_010: next_state <= WB_011;
            EXE_101: next_state <= MEM_110;
            MEM_110: begin
                case (inst[6:0])
                    7'b000_0011: next_state <= WB_111;
                    7'b010_0011: next_state <= IF;
                endcase
            end
            WB_011,
            EXE_100,
            WB_111: next_state <= IF;
            default: next_state <= IF;
        endcase
    end


    // insmemRW
    always @(posedge clk) begin
        insmemRW <= 0;
    end

    // regwEn
    always @(negedge clk) begin
        case (state)
            WB_011,
            WB_111: regwEn <= 1;
            default: regwEn <= 0;
        endcase
    end

    // PCWre - IF negedge write
    always @(state) begin
        case (state)
            IF: PCWre <= 1;
            default: PCWre <= 0;
        endcase
    end

    // IRWre
    always @(negedge clk) begin
        case (state)
            IF: IRWre <= 1;
            default: IRWre <= 0;
        endcase
    end

    // ExtSel
    always @(posedge clk) begin
        case (inst[6:0])
            7'b001_0011: begin
                case (inst[14:12])
                    3'b011: ExtSel <= 0;        // sltiu
                    default: ExtSel <= 1;
                endcase
            end
            7'b000_0011: begin
                case (inst[14:12])
                    3'b100,
                    3'b101: ExtSel <= 0;        // lbu,lhu
                    default: ExtSel <= 1;
                endcase
            end
            7'b110_0011: begin
                case (inst[14:12])
                    3'b110,
                    3'b111: ExtSel <= 0;        // bltu,bgeu
                    default: ExtSel <= 1;
                endcase
            end
            default: ExtSel <= 1;
        endcase
    end

    // pcsel
    always @(posedge clk) begin
        case (inst[6:0])
            7'b110_0011: begin
                case (inst[14:12])
                    3'b000: begin
                        if(breq==1) pcsel <= 0;
                        else pcsel <= 1;
                    end
                    3'b001: begin
                        if(breq==0) pcsel <= 0;
                        else pcsel <= 1;
                    end
                    3'b100,
                    3'b110: begin
                        if(brlt==0 && breq==0) pcsel <= 0;
                        else pcsel <= 1;
                    end
                    3'b101,
                    3'b111: begin
                        if(brlt==1 || breq==1) pcsel <= 0;
                        else pcsel <= 1;
                    end
                endcase
            end
            7'b110_1111,
            7'b110_0111: pcsel <= 0;
            default: pcsel <= 1;
        endcase
    end

    // asel
    always @(*) begin
        case (inst[6:0])
            7'b110_0011,
            7'b110_1111,
            7'b001_0111: asel <= 0;
            default: asel <= 1;
        endcase
    end

    // bsel
    always @(*) begin
        case (inst[6:0])
            7'b011_0011: bsel <= 0;
            default: bsel <= 1;
        endcase
    end

    // wbsel
    always @(*) begin
        case (inst[6:0])
            7'b000_0011: wbsel <= 2'b00;
            7'b011_0011,
            7'b001_0011,
            7'b011_0111,
            7'b001_0111: wbsel <= 2'b01;
            7'b110_1111,
            7'b110_0111: wbsel <= 2'b10;
            default: wbsel <= 2'b11;
        endcase
    end

    // brsel
    always @(*) begin
        case (inst[6:0])
            7'b011_0011: 
                case (inst[14:12])
                    3'b010: brsel <= 2'b00;
                    3'b011: brsel <= 2'b01;
                    default: brsel <= 2'b00;
                endcase
            7'b001_0011:
                case (inst[14:12])
                    3'b010: brsel <= 2'b10;
                    3'b011: brsel <= 2'b11;
                    default: brsel <= 2'b10;
                endcase
            7'b110_0011:
                case (inst[14:12])
                    3'b110,
                    3'b111: brsel <= 2'b01;
                    default: brsel <= 2'b00;
                endcase
            default: brsel <= 2'b00;
        endcase
    end

    // datarw
    always @(posedge clk) begin
        case (state)
            MEM_110: begin
                case (inst[6:0])
                    7'b000_0011:
                        case (inst[14:12])
                            3'b000: datarw <= 3'b000;
                            3'b001: datarw <= 3'b001;
                            3'b010: datarw <= 3'b100;
                            3'b100: datarw <= 3'b010;
                            3'b101: datarw <= 3'b011;
                        endcase
                    7'b010_0011: 
                        case (inst[14:12])
                            3'b000: datarw <= 3'b101;
                            3'b001: datarw <= 3'b110;
                            3'b010: datarw <= 3'b111;
                        endcase
                    default: datarw <= 3'b000;
                endcase
            end
            default: datarw <= 3'b000;
        endcase
    end

    // alusel
    always @(negedge clk) begin
        case (state)
            EXE_010,
            EXE_100,
            EXE_101: begin
            case (inst[6:0])
                7'b011_0011:
                    case (inst[14:12])
                        3'b000: 
                            case (inst[31:25])
                                7'b000_0000: alusel <= 4'b0000;
                                7'b010_0000: alusel <= 4'b0001;
                            endcase
                        3'b100:
                            case (inst[31:25])
                                7'b000_0000: alusel <= 4'b0010;
                            endcase
                        3'b110:
                            case (inst[31:25])
                                7'b000_0000: alusel <= 4'b0011;
                            endcase
                        3'b111:
                            case (inst[31:25])
                                7'b000_0000: alusel <= 4'b0100;
                            endcase
                        3'b001:
                            case (inst[31:25])
                                7'b000_0000: alusel <= 4'b0101;
                            endcase
                        3'b101:
                            case (inst[31:25])
                                7'b000_0000: alusel <= 4'b0111;
                                7'b010_0000: alusel <= 4'b1001;
                            endcase
                        3'b010,
                        3'b011:
                            case (inst[31:25])
                                7'b000_0000: begin 
                                    if(brlt==0 && breq==0)  alusel <= 4'b1011;
                                    else alusel <= 4'b1100;
                                end
                            endcase
                        default: alusel <= 4'b1111;
                    endcase
                7'b001_0011:
                    case (inst[14:12])
                        3'b000: alusel <= 4'b0000;
                        3'b100: alusel <= 4'b0010;
                        3'b110: alusel <= 4'b0011;
                        3'b111: alusel <= 4'b0100;
                        3'b001:
                            case (inst[31:25])
                                7'b000_0000: alusel <= 4'b0110;
                            endcase
                        3'b101:
                            case (inst[31:25])
                                7'b000_0000: alusel <= 4'b1000;
                                7'b010_0000: alusel <= 4'b1010;
                            endcase
                        3'b010,
                        3'b011: begin 
                            if(brlt==0 && breq==0)  alusel <= 4'b1011;
                            else alusel <= 4'b1100;
                        end
                        default: alusel <= 4'b1111;
                    endcase
                7'b000_0011,
                7'b010_0011,
                7'b110_0011,
                7'b110_1111,
                7'b110_0111: alusel <= 4'b0000;
                7'b011_0111: alusel <= 4'b1101;
                7'b001_0111: alusel <= 4'b1110;
                default: alusel <= 4'b1111;
            endcase
            end
            default: alusel <= 4'b0000;
        endcase
    end

endmodule
