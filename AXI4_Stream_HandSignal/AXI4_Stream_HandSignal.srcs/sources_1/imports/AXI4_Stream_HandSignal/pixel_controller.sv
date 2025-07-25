`timescale 1ns / 1ps

module pixel_controller(
    input  logic                   pclk,
    input  logic                   reset,
    output logic [$clog2(1920)-1:0] x_pixel,
    output logic [$clog2(1080)-1:0] y_pixel
);
    logic [$clog2(2200)-1:0] h_counter,v_counter;

    pixel_counter U_Pix_counter(.*);

    assign x_pixel = h_counter; 
    assign y_pixel = v_counter;

endmodule

module pixel_counter (
    input  logic                   pclk,
    input  logic                   reset,
    output logic [$clog2(1920)-1:0] h_counter,
    output logic [$clog2(1080)-1:0] v_counter
);
    localparam H_MAX = 2200, V_MAX = 1125;

    always_ff @(posedge pclk, posedge reset) begin : Horizontal_counter
        if (reset) begin
            h_counter <= 0;
        end else begin
            if (h_counter == H_MAX - 1) begin
                h_counter <= 0;
            end else begin
                h_counter <= h_counter + 1;
            end
        end
    end

    always_ff @(posedge pclk, posedge reset) begin : Vertical_counter
        if (reset) begin
            v_counter <= 0;
        end else begin
            if (h_counter == H_MAX -1) begin // h_counter이후 다음 라인으로 넘어와야 vertical이 하나 증가
                if (v_counter == V_MAX - 1) begin
                    v_counter <= 0;
                end else begin
                    v_counter <= v_counter + 1;
                end
            end
        end
    end
endmodule
