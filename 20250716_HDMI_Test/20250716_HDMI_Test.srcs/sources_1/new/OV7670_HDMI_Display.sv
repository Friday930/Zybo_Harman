`timescale 1ns / 1ps

module OV7670_HDMI_Display (
    // Global signals
    input  logic       clk,         // 100MHz system clock
    input  logic       reset,
    
    // OV7670 camera signals
    output logic       ov7670_xclk,    // Master clock to camera
    input  logic       ov7670_pclk,    // Pixel clock from camera
    input  logic       ov7670_href,    // Horizontal reference
    input  logic       ov7670_v_sync,  // Vertical sync
    input  logic [7:0] ov7670_data,    // Camera data
    
    // HDMI output signals
    output logic       hdmi_clk,     // HDMI pixel clock
    output logic       hdmi_hsync,   // HDMI horizontal sync
    output logic       hdmi_vsync,   // HDMI vertical sync
    output logic       hdmi_de,      // HDMI data enable
    output logic [7:0] hdmi_red,     // HDMI red channel
    output logic [7:0] hdmi_green,   // HDMI green channel
    output logic [7:0] hdmi_blue     // HDMI blue channel
);

    // Frame buffer interface signals
    logic        we;
    logic [16:0] wAddr;
    logic [15:0] wData;
    logic [16:0] rAddr;
    logic [15:0] rData;

    // HDMI timing signals
    logic [ 9:0] x_pixel;
    logic [ 9:0] y_pixel;
    logic        DE;
    logic        rclk;
    logic        oe;

    // Camera master clock generator (24MHz for OV7670)
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
        .h_sync  (hdmi_hsync),
        .v_sync  (hdmi_vsync),
        .DE      (hdmi_de),
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
        .DE        (hdmi_de),
        .rclk      (rclk),
        .d_en      (oe),
        .rAddr     (rAddr),
        .rData     (rData),
        .hdmi_red  (hdmi_red),
        .hdmi_green(hdmi_green),
        .hdmi_blue (hdmi_blue)
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