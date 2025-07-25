`timescale 1ns / 1ps

module AXI4_HandSignal(
    input           aclk,
    input           pclk,
    input           aresetn,
    // AXI4S Slave 입력
    input   [23:0]  s_axis_tdata,
    input           s_axis_tvalid,
    output          s_axis_tready,
    input           s_axis_tlast,
    input           s_axis_tuser,
    // AXI4S Master 출력
    output   reg [23:0]  m_axis_tdata,
    output   reg        m_axis_tvalid,
    input            m_axis_tready,
    output     reg        m_axis_tlast,
    output    reg       m_axis_tuser,

    // SPI 입력
    output   [31:0]  o_color_spi_data
);

    // Filter 결과 (동기화)
    wire [23:0] filtered_pixel;
    reg  [23:0] data_reg, data_reg_next;
    reg         last_reg, user_reg;
    reg         valid_reg;

    // filter inst
    TOP_Hand_Signal u_filter (
        .clk(aclk),
        .reset(~aresetn),
        .pclk(pclk),
        .i_cam_RGB_data(s_axis_tdata),
        .o_cam_RGB_data(filtered_pixel),
        .o_color_spi_data(o_color_spi_data)
    );

    always @(posedge aclk) begin
        if (!aresetn) begin
            m_axis_tvalid <= 1'b0;
        end else begin
            // 입력이 유효하고, 출력이 준비됐을 때만 데이터 전송
            if (s_axis_tvalid && m_axis_tready) begin
                m_axis_tdata  <= filtered_pixel;
                m_axis_tvalid <= 1'b1;
                m_axis_tlast  <= s_axis_tlast;
                m_axis_tuser  <= s_axis_tuser;
            end else if (m_axis_tvalid && !m_axis_tready) begin
                // 출력 대기 
                m_axis_tvalid <= m_axis_tvalid; // 유지
            end else begin
                m_axis_tvalid <= 1'b0;
            end
        end
    end

    // 입력 ready는 출력 ready와 같음
    assign s_axis_tready = (!m_axis_tvalid) || m_axis_tready;

endmodule

