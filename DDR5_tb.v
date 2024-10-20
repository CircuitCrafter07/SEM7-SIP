module DDR5_Memory_tb;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg [15:0] addr;
    reg [63:0] wr_data;
    reg rd_en;
    reg wr_en;
    wire [63:0] rd_data;

    // Instantiate the DDR5_Memory module
    DDR5_Memory uut (
        .clk(clk),
        .rst_n(rst_n),
        .addr(addr),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .rd_data(rd_data)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz clock period
    end

    // Test sequence
    initial begin
        // Initialize signals
        rst_n = 0;
        addr = 0;
        wr_data = 0;
        rd_en = 0;
        wr_en = 0;

        // Reset the system
        #15 rst_n = 1;

        // Write some data to the memory
        @(posedge clk);
        addr = 16'h0000;
        wr_data = 64'h123456789ABCDEF0;
        wr_en = 1;
        #10 wr_en = 0;

        @(posedge clk);
        addr = 16'h0001;
        wr_data = 64'hFEDCBA9876543210;
        wr_en = 1;
        #10 wr_en = 0;

        // Read the data back from the memory
        #20;
        @(posedge clk);
        addr = 16'h0000;
        rd_en = 1;
        #10 rd_en = 0;

        @(posedge clk);
        addr = 16'h0001;
        rd_en = 1;
        #10 rd_en = 0;

        // Additional reads and writes if needed
        #200 $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time: %0t | clk: %b | addr: %h | wr_data: %h | rd_data: %h | rd_en: %b | wr_en: %b",
                 $time, clk, addr, wr_data, rd_data, rd_en, wr_en);
    end

endmodule
