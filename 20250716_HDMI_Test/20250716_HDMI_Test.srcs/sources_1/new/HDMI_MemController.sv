`timescale 1ns / 1ps

module HDMI_MemController (
    // HDMI Controller side
    input  logic        clk,
    input  logic [ 9:0] x_pixel,
    input  logic [ 9:0] y_pixel,
    input  logic        DE,
    // frame buffer side
    output logic        rclk,
    output logic        d_en,
    output logic [16:0] rAddr,
    input  logic [15:0] rData,
    // HDMI export side
    output logic [ 7:0] hdmi_red,
    output logic [ 7:0] hdmi_green,
    output logic [ 7:0] hdmi_blue
);

    logic display_en;
    logic [4:0] red_5bit, blue_5bit;
    logic [5:0] green_6bit;

    assign rclk = clk;
    assign display_en = (x_pixel < 320) && (y_pixel < 240);
    assign d_en = display_en;

    assign rAddr = display_en ? (y_pixel * 320 + x_pixel) : 0;
    
    // Extract RGB from 16-bit RGB565 format
    assign red_5bit   = display_en ? rData[15:11] : 5'b0;
    assign green_6bit = display_en ? rData[10:5]  : 6'b0;
    assign blue_5bit  = display_en ? rData[4:0]   : 5'b0;
    
    // Convert to 8-bit RGB for HDMI
    assign hdmi_red   = {red_5bit, red_5bit[4:2]};      // Replicate MSBs
    assign hdmi_green = {green_6bit, green_6bit[5:4]};  // Replicate MSBs
    assign hdmi_blue  = {blue_5bit, blue_5bit[4:2]};    // Replicate MSBs

endmodule