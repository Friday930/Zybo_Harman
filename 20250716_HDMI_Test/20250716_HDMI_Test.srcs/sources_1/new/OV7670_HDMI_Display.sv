`timescale 1ns / 1ps

module OV7670_HDMI_Display (
    // Global signals
    input  logic       clk,         // 125MHz 시스템 클럭
    input  logic       reset,
    
    // OV7670 camera signals
    output logic       ov7670_xclk,    // Master clock to camera
    input  logic       ov7670_pclk,    // Pixel clock from camera
    input  logic       ov7670_href,    // Horizontal reference
    input  logic       ov7670_v_sync,  // Vertical sync
    input  logic [7:0] ov7670_data,    // Camera data
    
    // HDMI TMDS output signals (차동 신호로 정의)
    output logic       tmds_clk_p,      // TMDS clock positive
    output logic       tmds_clk_n,      // TMDS clock negative  
    output logic [2:0] tmds_data_p,     // TMDS data positive
    output logic [2:0] tmds_data_n      // TMDS data negative
);

    // Frame buffer interface signals
    logic        we;
    logic [16:0] wAddr;
    logic [15:0] wData;
    logic [16:0] rAddr;
    logic [15:0] rData;

    // Video timing signals
    logic [ 9:0] x_pixel;
    logic [ 9:0] y_pixel;
    logic        DE;
    logic        rclk;
    logic        oe;
    logic        hdmi_clk;
    logic        h_sync, v_sync;

    // RGB signals for HDMI
    logic [7:0] hdmi_red, hdmi_green, hdmi_blue;

    // Camera master clock generator (약 25MHz for OV7670)
    pixel_clk_gen U_OV7670_Clk_Gen (
        .clk  (clk),
        .reset(reset),
        .pclk (ov7670_xclk)
    );

    // HDMI timing controller
    HDMI_Controller U_HDMI_Controller (
        .clk     (clk),
        .reset   (reset),
        .hdmi_clk(hdmi_clk),
        .h_sync  (h_sync),
        .v_sync  (v_sync),
        .DE      (DE),
        .x_pixel (x_pixel),
        .y_pixel (y_pixel)
    );

    // Camera data to frame buffer controller
    OV7670_MemController U_OV7670_MemController (
        .pclk       (ov7670_pclk),
        .reset      (reset),
        .href       (ov7670_href),
        .v_sync     (ov7670_v_sync),
        .ov7670_data(ov7670_data),
        .we         (we),
        .wAddr      (wAddr),
        .wData      (wData)
    );

    // Dual-port frame buffer
    frame_buffer U_Frame_Buffer (
        .wclk (ov7670_pclk),
        .we   (we),
        .wAddr(wAddr),
        .wData(wData),
        .rclk (rclk),
        .oe   (oe),
        .rAddr(rAddr),
        .rData(rData)
    );

    // QVGA to HDMI memory controller
    HDMI_MemController U_HDMI_MemController (
        .clk       (hdmi_clk),
        .x_pixel   (x_pixel),
        .y_pixel   (y_pixel),
        .DE        (DE),
        .rclk      (rclk),
        .d_en      (oe),
        .rAddr     (rAddr),
        .rData     (rData),
        .hdmi_red  (hdmi_red),
        .hdmi_green(hdmi_green),
        .hdmi_blue (hdmi_blue)
    );

    // HDMI TMDS 컨트롤러
    HDMI_TMDS_Controller U_HDMI_TMDS_Controller (
        .clk_125mhz    (clk),
        .reset         (reset),
        .red_in        (hdmi_red),
        .green_in      (hdmi_green),
        .blue_in       (hdmi_blue),
        .hsync_in      (h_sync),
        .vsync_in      (v_sync),
        .de_in         (DE),
        .tmds_clk_p    (tmds_clk_p),
        .tmds_clk_n    (tmds_clk_n),
        .tmds_data_p   (tmds_data_p),
        .tmds_data_n   (tmds_data_n)
    );

endmodule

// OV7670 카메라용 마스터 클럭 생성기 (24MHz)
module pixel_clk_gen (
    input  logic clk,     // 100MHz 시스템 클럭
    input  logic reset,
    output logic pclk     // 24MHz 출력 (OV7670 XCLK용)
);
    logic [1:0] p_counter;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            p_counter <= 0;
            pclk <= 1'b0;
        end else begin
            if (p_counter == 3) begin
                p_counter <= 0;
                pclk <= 1'b1;
            end else begin
                p_counter <= p_counter + 1;
                pclk <= 1'b0;
            end
        end
    end
    
endmodule