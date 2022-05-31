`timescale 1ns / 1ps
module sim();
    // input
    reg clk;                    // clk for LED_display
    reg reset;                  // reset sign
    reg clkin_n;                // clkin for PC
    reg [2:0]SW;                // select data to LED_display
    // output
    wire [7:0] LED_display;     // Seven segment nixie tube display
    wire [3:0] LED_pos;         // position selection
    Multi_circle_CPU CPU(
        .clk(clk),
        .clkin_n(clkin_n),
        .reset(reset),
        .SW(SW),
        .LED_display(LED_display),
        .LED_pos(LED_pos)
    );

    always #3 clk = ~clk; // 周期为ns
    always #18 clkin_n = ~clkin_n; // 周期为ns
    initial begin
        clk <= 0;
        clkin_n <= 0;
        reset <= 1;
        SW <= 3'b000;
        #50 reset = 0; // 从50ns开始仿真输出
    end
endmodule
