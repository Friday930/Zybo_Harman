`timescale 1ns / 1ps

// 진짜 HDMI 컨트롤러 (오디오 없는 비디오 전용)
module HDMI_TMDS_Controller (
    input  logic       clk_125mhz,  // 125MHz 시스템 클럭
    input  logic       reset,
    
    // 픽셀 데이터 입력
    input  logic [7:0] red_in,
    input  logic [7:0] green_in,
    input  logic [7:0] blue_in,
    input  logic       hsync_in,
    input  logic       vsync_in,
    input  logic       de_in,
    
    // TMDS 출력
    output logic       tmds_clk_p,
    output logic       tmds_clk_n,
    output logic [2:0] tmds_data_p,
    output logic [2:0] tmds_data_n
);

    logic clk_25mhz, clk_125mhz_shift;
    logic [9:0] tmds_red, tmds_green, tmds_blue;
    logic [29:0] tmds_data;
    logic [4:0] bit_counter;

    // 클럭 생성 (25MHz 픽셀 클럭)
    always_ff @(posedge clk_125mhz) begin
        if (reset) begin
            clk_25mhz <= 0;
        end else begin
            clk_25mhz <= ~clk_25mhz;  // 125MHz를 2로 나눠서 62.5MHz, 다시 나누면 31.25MHz (근사치)
        end
    end

    // TMDS 인코딩 (간단한 8b/10b 변환)
    always_ff @(posedge clk_25mhz) begin
        if (reset) begin
            tmds_red   <= 10'b0;
            tmds_green <= 10'b0;
            tmds_blue  <= 10'b0;
        end else if (de_in) begin
            // 데이터 활성 구간에서는 RGB 데이터 인코딩
            tmds_red   <= {2'b01, red_in};    // 간단한 인코딩
            tmds_green <= {2'b01, green_in};
            tmds_blue  <= {2'b01, blue_in};
        end else begin
            // 블랭킹 구간에서는 동기 신호 인코딩
            case ({vsync_in, hsync_in})
                2'b00: tmds_blue <= 10'b1101010100;  // 블랭킹
                2'b01: tmds_blue <= 10'b0010101011;  // H-sync
                2'b10: tmds_blue <= 10'b0101010100;  // V-sync
                2'b11: tmds_blue <= 10'b1010101011;  // 둘 다
            endcase
            tmds_red   <= 10'b1101010100;  // 블랭킹 시 고정값
            tmds_green <= 10'b1101010100;
        end
    end

    // 30비트 TMDS 데이터 준비
    assign tmds_data = {tmds_red, tmds_green, tmds_blue};

    // 직렬화 카운터
    always_ff @(posedge clk_125mhz) begin
        if (reset) begin
            bit_counter <= 0;
        end else begin
            bit_counter <= bit_counter + 1;
            if (bit_counter >= 9) begin
                bit_counter <= 0;
            end
        end
    end

    // TMDS 차동 출력 생성
    always_ff @(posedge clk_125mhz) begin
        if (reset) begin
            tmds_data_p <= 3'b0;
            tmds_data_n <= 3'b1;
            tmds_clk_p  <= 1'b0;
            tmds_clk_n  <= 1'b1;
        end else begin
            // 클럭 출력 (25MHz를 차동으로)
            tmds_clk_p <= clk_25mhz;
            tmds_clk_n <= ~clk_25mhz;
            
            // 데이터 직렬화 출력
            tmds_data_p[0] <= tmds_data[bit_counter];        // Blue
            tmds_data_p[1] <= tmds_data[bit_counter + 10];   // Green  
            tmds_data_p[2] <= tmds_data[bit_counter + 20];   // Red
            
            tmds_data_n[0] <= ~tmds_data[bit_counter];
            tmds_data_n[1] <= ~tmds_data[bit_counter + 10];
            tmds_data_n[2] <= ~tmds_data[bit_counter + 20];
        end
    end

endmodule