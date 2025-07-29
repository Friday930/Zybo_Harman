`timescale 1ns / 1ps

module TOP_Hand_Signal(
    input logic clk,
    input logic [9:0] x_pixel,
    input logic [9:0] y_pixel,
    input logic ov7670_pclk,
    input logic [7:0] ov7670_Red,
    input logic [7:0] ov7670_Green,
    input logic [7:0] ov7670_Blue,
    output logic [7:0] blue_x, blue_y,
    output logic [7:0] red_x, red_y,
    output logic [7:0] vgaRed,
    output logic [7:0] vgaGreen,
    output logic [7:0] vgaBlue
    );

    localparam NX = 10, NY = 8, ZONES = NX * NY, ZBW = $clog2(ZONES);
    wire [ZBW-1:0] zone_id;
    wire w_pclk;
    wire [6:0] blue_flag, red_flag;

    assign w_pclk = ov7670_pclk;
    assign blue_x = blue_flag % NX;
    assign blue_y = blue_flag / NX;
    assign red_x = red_flag % NX;
    assign red_y = red_flag / NX;

    AreaSel  u_AreaSel (
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .zone_id(zone_id)
    );

    hand_signal u_hand_signal (
        .clk        (clk),
        .rst        (reset),
        .pclk       (w_pclk),
        .x_pixel    (x_pixel),
        .y_pixel    (y_pixel),
        .zone_id    (zone_id),
        .pixel_COLOR({ov7670_Red, ov7670_Green, ov7670_Blue}),
        .blue_flag  (blue_flag),
        .red_flag   (red_flag)
    );

    print_grid u_print_grid (
        .R        (ov7670_Red),
        .G        (ov7670_Green),
        .B        (ov7670_Blue),
        .x        (x_pixel),
        .y        (y_pixel),
        .blue_flag(blue_flag),
        .red_flag (red_flag),
        .o_R      (vgaRed),
        .o_G      (vgaGreen),
        .o_B      (vgaBlue)
    );

endmodule
