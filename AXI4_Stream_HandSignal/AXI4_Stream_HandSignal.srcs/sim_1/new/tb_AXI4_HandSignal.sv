`timescale 1ns / 1ps

module tb_AXI4_HandSignal;

    // Clock and Reset
    reg aclk;
    reg pclk;
    reg aresetn;
    
    // AXI4S Slave Interface (Input)
    reg  [23:0] s_axis_tdata;
    reg         s_axis_tvalid;
    wire        s_axis_tready;
    reg         s_axis_tlast;
    reg         s_axis_tuser;
    
    // AXI4S Master Interface (Output)
    wire [23:0] m_axis_tdata;
    wire        m_axis_tvalid;
    reg         m_axis_tready;
    wire        m_axis_tlast;
    wire        m_axis_tuser;
    
    // SPI Output
    wire [31:0] o_color_spi_data;
    
    // Test variables
    integer pixel_count;
    reg [23:0] test_pixels [0:99]; // Test pixel data array
    
    // DUT instantiation
    AXI4_HandSignal uut (
        .aclk(aclk),
        .pclk(pclk),
        .aresetn(aresetn),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tuser(s_axis_tuser),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tuser(m_axis_tuser),
        .o_color_spi_data(o_color_spi_data)
    );
    
    // Clock generation
    // aclk: 150MHz (6.67ns period)
    initial begin
        aclk = 0;
        forever #3.33 aclk = ~aclk;
    end
    
    // pclk: 68MHz (14.7ns period)  
    initial begin
        pclk = 0;
        forever #7.35 pclk = ~pclk;
    end
    
    // Initialize test pixel data
    initial begin
        // Red pixels (R=255, G=0, B=0)
        for (int i = 0; i < 30; i++) begin
            test_pixels[i] = 24'hFF0000;
        end
        // Blue pixels (R=0, G=0, B=255)
        for (int i = 30; i < 60; i++) begin
            test_pixels[i] = 24'h0000FF;
        end
        // Green pixels (R=0, G=255, B=0)
        for (int i = 60; i < 80; i++) begin
            test_pixels[i] = 24'h00FF00;
        end
        // White pixels (R=255, G=255, B=255)
        for (int i = 80; i < 100; i++) begin
            test_pixels[i] = 24'hFFFFFF;
        end
    end
    
    // Reset sequence
    initial begin
        aresetn = 0;
        s_axis_tdata = 0;
        s_axis_tvalid = 0;
        s_axis_tlast = 0;
        s_axis_tuser = 0;
        m_axis_tready = 0;
        pixel_count = 0;
        
        // Reset for 100ns
        #100;
        aresetn = 1;
        #50;
        
        $display("=== AXI4-Stream HandSignal Test Started ===");
        
        // Test Case 1: Basic handshake with ready always high
        test_basic_handshake();
        
        #1000;
        
        // Test Case 2: Backpressure test (ready intermittent)
        test_backpressure();
        
        #1000;
        
        // Test Case 3: Burst transfer test
        test_burst_transfer();
        
        #2000;
        
        $display("=== All Tests Completed ===");
        $finish;
    end
    
    // Test Case 1: Basic handshake
    task test_basic_handshake();
        begin
            $display("\n--- Test Case 1: Basic Handshake ---");
            m_axis_tready = 1'b1; // Always ready
            
            for (int i = 0; i < 20; i++) begin
                @(posedge aclk);
                s_axis_tdata = test_pixels[i];
                s_axis_tvalid = 1'b1;
                s_axis_tlast = (i == 19) ? 1'b1 : 1'b0;
                s_axis_tuser = (i == 0) ? 1'b1 : 1'b0;
                
                // Wait for ready
                while (!s_axis_tready) @(posedge aclk);
                
                // Check handshake
                if (s_axis_tvalid && s_axis_tready) begin
                    $display("Time %0t: Input Handshake - Data: 0x%06h, Last: %b, User: %b", 
                             $time, s_axis_tdata, s_axis_tlast, s_axis_tuser);
                end
                
                @(posedge aclk);
                s_axis_tvalid = 1'b0;
                s_axis_tlast = 1'b0;
                s_axis_tuser = 1'b0;
            end
            
            // Wait for output
            repeat(10) @(posedge aclk);
        end
    endtask
    
    // Test Case 2: Backpressure test
    task test_backpressure();
        begin
            $display("\n--- Test Case 2: Backpressure Test ---");
            
            for (int i = 20; i < 40; i++) begin
                @(posedge aclk);
                s_axis_tdata = test_pixels[i];
                s_axis_tvalid = 1'b1;
                s_axis_tlast = (i == 39) ? 1'b1 : 1'b0;
                s_axis_tuser = (i == 20) ? 1'b1 : 1'b0;
                
                // Random ready control for backpressure
                m_axis_tready = $random % 2;
                
                // Wait for ready
                while (!s_axis_tready) begin
                    @(posedge aclk);
                    m_axis_tready = $random % 2;
                end
                
                $display("Time %0t: Backpressure Test - Data: 0x%06h, m_ready: %b", 
                         $time, s_axis_tdata, m_axis_tready);
                
                @(posedge aclk);
                s_axis_tvalid = 1'b0;
                s_axis_tlast = 1'b0;
                s_axis_tuser = 1'b0;
            end
            
            m_axis_tready = 1'b1; // Return to always ready
            repeat(10) @(posedge aclk);
        end
    endtask
    
    // Test Case 3: Burst transfer
    task test_burst_transfer();
        begin
            $display("\n--- Test Case 3: Burst Transfer Test ---");
            m_axis_tready = 1'b1;
            
            // Send burst of pixels
            for (int i = 60; i < 100; i++) begin
                @(posedge aclk);
                s_axis_tdata = test_pixels[i];
                s_axis_tvalid = 1'b1;
                s_axis_tlast = (i == 99) ? 1'b1 : 1'b0;
                s_axis_tuser = (i == 60) ? 1'b1 : 1'b0;
                
                if (s_axis_tvalid && s_axis_tready) begin
                    $display("Time %0t: Burst Transfer - Pixel %0d: 0x%06h", 
                             $time, i, s_axis_tdata);
                end
            end
            
            @(posedge aclk);
            s_axis_tvalid = 1'b0;
            s_axis_tlast = 1'b0;
            s_axis_tuser = 1'b0;
            
            repeat(20) @(posedge aclk);
        end
    endtask
    
    // Monitor output handshake
    always @(posedge aclk) begin
        if (m_axis_tvalid && m_axis_tready) begin
            $display("Time %0t: Output Handshake - Data: 0x%06h, Last: %b, User: %b, SPI: 0x%08h", 
                     $time, m_axis_tdata, m_axis_tlast, m_axis_tuser, o_color_spi_data);
        end
    end
    
    // Monitor ready signals
    always @(posedge aclk) begin
        if (!s_axis_tready && s_axis_tvalid) begin
            $display("Time %0t: INPUT STALLED - Valid high but Ready low", $time);
        end
        if (!m_axis_tready && m_axis_tvalid) begin
            $display("Time %0t: OUTPUT STALLED - Valid high but Ready low", $time);
        end
    end
    
    // Protocol violation checker
    always @(posedge aclk) begin
        if (aresetn) begin
            // Check if valid goes low while ready is low (protocol violation)
            if ($past(m_axis_tvalid) && $past(!m_axis_tready) && !m_axis_tvalid) begin
                $error("Time %0t: PROTOCOL VIOLATION - m_axis_tvalid went low while m_axis_tready was low", $time);
            end
        end
    end
    
    // Performance monitoring
    integer input_transactions = 0;
    integer output_transactions = 0;
    
    always @(posedge aclk) begin
        if (aresetn) begin
            if (s_axis_tvalid && s_axis_tready) 
                input_transactions++;
            if (m_axis_tvalid && m_axis_tready) 
                output_transactions++;
        end
    end
    
    // Final report
    final begin
        $display("\n=== Final Report ===");
        $display("Input Transactions: %0d", input_transactions);
        $display("Output Transactions: %0d", output_transactions);
        $display("Final SPI Output: 0x%08h", o_color_spi_data);
    end

endmodule
