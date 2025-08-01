`timescale 1ns / 1ps

module SPI_Master #(
    parameter SLAVE_CS   = 2,
    parameter DATA_WIDTH = 8,
    parameter SCLK_DIV   = 125  // 125MHz/SCLK_DIV = SPI clock
) (
    // global signals
    input            clk,
    input            reset,
    // internal signals
    input            cpol,
    input            cpha,
    input            start,
    input      [7:0] tx_data,
    output     [7:0] rx_data,
    output reg       done,
    output reg       ready,
    input            slave_sel,
    //external port
    output           SCLK,
    output           MOSI,
    input            MISO,
    output     [1:0] CS
);

    reg [1:0] cs_reg;
    assign CS = cs_reg;

    localparam IDLE = 0, CP_DELAY = 1, CP0 = 2, CP1 = 3;

    reg [1:0] state, state_next;
    reg [7:0] temp_tx_data_next, temp_tx_data_reg;
    reg [7:0] temp_rx_data_next, temp_rx_data_reg;
    reg [$clog2(SCLK_DIV)-1:0] sclk_counter_next, sclk_counter_reg;
    reg [$clog2(DATA_WIDTH)-1:0] bit_counter_next, bit_counter_reg;
    wire r_sclk;

    assign MOSI = temp_tx_data_reg[7];
    assign rx_data = temp_rx_data_reg;
    // assign r_sclk = (state_next == CP1 && ~cpha) || (state_next == CP0 && cpha);
    // assign SCLK = cpol ? ~r_sclk : r_sclk;
    reg sclk_reg;

    always @(posedge clk) begin
        if (reset) begin
            sclk_reg <= cpol;  // 초기값을 cpol로
        end else begin
            case (state)
                CP0: begin
                    if (sclk_counter_reg == SCLK_DIV - 1) begin
                        sclk_reg <= ~cpol;  // CP1으로 갈 때 토글
                    end
                end
                CP1: begin
                    if (sclk_counter_reg == SCLK_DIV - 1) begin
                        sclk_reg <= cpol;   // CP0으로 갈 때 토글
                    end
                end
                default: begin
                    sclk_reg <= cpol;   // IDLE일 때 기본값
                end
            endcase
        end
    end

    assign SCLK = sclk_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            temp_tx_data_reg <= 0;
            temp_rx_data_reg <= 0;
            sclk_counter_reg <= 0;
            bit_counter_reg <= 0;
        end else begin
            state <= state_next;
            temp_tx_data_reg <= temp_tx_data_next;
            temp_rx_data_reg <= temp_rx_data_next;
            sclk_counter_reg <= sclk_counter_next;
            bit_counter_reg <= bit_counter_next;
        end
    end

    always @(*) begin
        state_next        = state;
        temp_tx_data_next = temp_tx_data_reg;
        temp_rx_data_next = temp_rx_data_reg;
        ready             = 0;
        done              = 0;
        cs_reg            = {SLAVE_CS{1'b1}};
        sclk_counter_next = sclk_counter_reg;
        bit_counter_next  = bit_counter_reg;
        
        case (state)
            IDLE: begin
                ready             = 1;
                cs_reg[slave_sel] = 1'b0;
                if (start) begin
                    temp_tx_data_next = tx_data;
                    ready             = 0;
                    sclk_counter_next = 0;
                    bit_counter_next  = 0;
                    cs_reg[slave_sel] = 1'b0;
                    state_next        = cpha ? CP_DELAY : CP0;
                end
            end
            CP_DELAY: begin
                cs_reg[slave_sel] = 1'b1;
                if (sclk_counter_reg == SCLK_DIV - 1) begin
                    sclk_counter_next = 0;
                    state_next = CP0;
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
            CP0: begin
                cs_reg[slave_sel] = 1'b1;
                if (sclk_counter_reg == SCLK_DIV - 1) begin
                    temp_rx_data_next = {temp_rx_data_reg[6:0], MISO};
                    sclk_counter_next = 0;
                    state_next        = CP1;
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
            CP1: begin
                cs_reg[slave_sel] = 1'b1;
                if (sclk_counter_reg == SCLK_DIV - 1) begin
                    if (bit_counter_reg == DATA_WIDTH - 1) begin
                        done = 1;
                        // 한 번만 전송 - 무조건 IDLE로 이동
                        state_next = IDLE;
                    end else begin
                        temp_tx_data_next = {temp_tx_data_reg[6:0], 1'b0};
                        sclk_counter_next = 0;
                        bit_counter_next  = bit_counter_reg + 1;
                        state_next        = CP0;
                    end
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
        endcase
    end
endmodule