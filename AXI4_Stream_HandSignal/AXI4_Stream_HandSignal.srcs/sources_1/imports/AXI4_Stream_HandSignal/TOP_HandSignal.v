`timescale 1ns / 1ps

module TOP_Hand_Signal(
    input  clk,
    input  reset,
    input  pclk,
    input  [23:0] i_cam_RGB_data,
    output  [31:0] o_color_spi_data,
    output   [23:0] o_cam_RGB_data
);

    localparam NX = 10, NY = 8, ZONES = NX * NY, ZBW = $clog2(ZONES);
    wire [10:0] x_pixel, y_pixel;
    wire [7:0] Red, Green, Blue;
    wire [ZBW-1:0] zone_id;
    wire [6:0] blue_flag, red_flag;
    wire [7:0] blue_x, blue_y;
    wire [7:0] red_x, red_y;
    wire [7:0] cam_Red, cam_Green, cam_Blue;

    assign blue_x = blue_flag % NX;
    assign blue_y = blue_flag / NX;
    assign red_x = red_flag % NX;
    assign red_y = red_flag / NX;

    assign o_color_spi_data = { red_x, blue_y, blue_x, red_y };
    assign o_cam_RGB_data = {Red, Green, Blue};
    assign cam_Red = i_cam_RGB_data[23:16];
    assign cam_Green = i_cam_RGB_data[15:8];
    assign cam_Blue = i_cam_RGB_data[7:0];
    // wire [23:0] cam_RGB_data = i_cam_RGB_data;


    pixel_controller U_pixel_controller(
        .pclk(pclk),
        .reset(reset),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel)
    );

    AreaSel  u_AreaSel (
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .zone_id(zone_id)
    );

    hand_signal u_hand_signal (
        .clk        (clk),
        .rst        (reset),
        .pclk       (pclk),
        .x_pixel    (x_pixel),
        .y_pixel    (y_pixel),
        .zone_id    (zone_id),
        .pixel_COLOR(cam_RGB_data),
        .blue_flag  (blue_flag),
        .red_flag   (red_flag)
    );

    print_grid u_print_grid (
        .R        (cam_Red),
        .G        (cam_Green),
        .B        (cam_Blue),
        .x        (x_pixel),
        .y        (y_pixel),
        .blue_flag(blue_flag),
        .red_flag (red_flag),
        .o_R      (Red),
        .o_G      (Green),
        .o_B      (Blue)
    );

endmodule
