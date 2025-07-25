module print_grid #(
    parameter X_SIZE = 1920,   // 화면 폭
    parameter Y_SIZE = 1080,   // 화면 높이
    parameter NX     = 10,    // 가로 칸 수
    parameter NY     = 8     // 세로 칸 수
) (
    input        [7:0] R, G, B,
    input        [10:0] x,
    input        [10:0] y,
    input        [6:0] blue_flag,
    input        [6:0] red_flag,
    input        [$clog2(NX*NY)-1:0] zone_id,
    output logic [7:0] o_R,
    output logic [7:0] o_G,
    output logic [7:0] o_B
);
    localparam X_UNIT = X_SIZE / NX;  // 예: 640/16 = 40
    localparam Y_UNIT = Y_SIZE / NY;  // 예: 480/12 = 40
    integer i;
    always_comb begin : PRINT_LOGIC
        {o_R, o_G, o_B} = {R, G, B};
        for (i = 1; i < NX; i = i + 1) begin
            if (x == X_UNIT * i) begin
                o_R = 8'h0; o_G = 8'hF; o_B = 8'h0; 
            end
        end
        for (i = 1; i < NY; i = i + 1) begin
            if (y == Y_UNIT * i) begin
                o_R = 8'h0; o_G = 8'hF; o_B = 8'h0;  
            end
        end
    end
endmodule