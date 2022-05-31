`timescale 1ns / 1ps
module Seg_LED(
    input clk,                          // 100MHz clock
    input [15:0] display_data,          // data display
    output [3:0] led_pos,               // position select
    output [7:0] led_segment            // segment select
    );

    // frequency division
    integer div_cnt;
    reg clk_div;

    initial begin
        div_cnt <= 0;
        clk_div <= 0;
    end

    always @(posedge clk) begin
        if(div_cnt==32'd100000) begin   // div_cnt = ((clk/clk_div)-2)/2
            div_cnt <= 1'b0;
            clk_div <= ~clk_div;
        end
        else div_cnt <= div_cnt + 1'b1;
    end

    // pos control
    reg [3:0] pos_ctrl = 4'b1110;
    always @(posedge clk_div) begin
        pos_ctrl <= {pos_ctrl[2:0], pos_ctrl[3]};
    end

    // segment contol
    reg [3:0] segment_ctrl;
    always @(pos_ctrl or display_data) begin
       case (pos_ctrl)
            4'b1110: segment_ctrl <= display_data[3:0];
            4'b1101: segment_ctrl <= display_data[7:4];
            4'b1011: segment_ctrl <= display_data[11:8];
            4'b0111: segment_ctrl <= display_data[15:12];
           default: segment_ctrl <= 4'hf;
       endcase 
    end

    // segment control
    reg [7:0] segment;
    always @(segment_ctrl)
        case(segment_ctrl)
            4'b0000 : segment <= 8'b1100_0000; //0  '0'-light up
            4'b0001 : segment <= 8'b1111_1001; //1
            4'b0010 : segment <= 8'b1010_0100; //2
            4'b0011 : segment <= 8'b1011_0000; //3
            4'b0100 : segment <= 8'b1001_1001; //4
            4'b0101 : segment <= 8'b1001_0010; //5
            4'b0110 : segment <= 8'b1000_0010; //6
            4'b0111 : segment <= 8'b1100_0000; //7
            4'b1000 : segment <= 8'b1000_0000; //8
            4'b1001 : segment <= 8'b1001_0000; //9
            4'b1010 : segment <= 8'b1000_1000; //A
            4'b1011 : segment <= 8'b1000_0011; //b
            4'b1100 : segment <= 8'b1100_0110; //C
            4'b1101 : segment <= 8'b1010_0001; //d
            4'b1110 : segment <= 8'b1000_0110; //E
            4'b1111 : segment <= 8'b1000_1110; //F
            default : segment <= 8'b0000_0000; //none
        endcase

    assign led_pos = pos_ctrl;
    assign led_segment = segment;
endmodule
