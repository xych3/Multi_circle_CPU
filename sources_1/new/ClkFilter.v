`timescale 1ns / 1ps
module ClkFilter(
    input clk,              // 100MHz clk
    input reset,            // recount
    input clkin_n,          // clock input
    output reg clkin        // anti shake clock
    );
    reg [19:0] cnt;
    reg cnt_full;

    initial begin
        clkin <= 0;
    end
    always @(posedge clk) begin
        if(reset) cnt <= 20'b0;
        else if (clkin_n==1) cnt <= cnt + 1'b1;
        else cnt <= 20'b0;
    end

    // normal

    // always @(posedge clk) begin
    //     if(reset) cnt_full <= 1'b0;
    //     else if(cnt==499999) cnt_full <= 1'b1;  // 100MHz-10ns,5ms-500000 cycle
    //     else if(clkin_n==0) cnt_full <= 1'b0;
    //     else cnt_full <= cnt_full;
    // end

    // always @(posedge clk) begin
    //     if(reset) clkin <= 1'b0;
    //     else if(cnt==499999 && cnt_full==1'b0) clkin <= 1'b1;
    //     else clkin <= 1'b0;
    // end


    // sim
    
    always @(posedge clk) begin
        if(reset) cnt_full <= 1'b0;
        else if(cnt==3) cnt_full <= 1'b1;
        else if(clkin_n==0) cnt_full <= 1'b0;
        else cnt_full <= cnt_full;
    end

    always @(posedge clk) begin
        if(reset) clkin <= 1'b0;
        else if(cnt==3 && cnt_full==1'b0) clkin <= 1'b1;
        else clkin <= 1'b0;
    end
endmodule
