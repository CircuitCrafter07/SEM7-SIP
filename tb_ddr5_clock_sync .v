module tb_ddr5_clock_sync;

    // Inputs
    reg clk;
    reg rst_n;
    reg [63:0] data_in;
    reg wr_en;

    // Outputs
    wire [63:0] data_out;
    wire sync_data_ready;

    // Instantiate the Unit Under Test (UUT)
    ddr5_clock_sync uut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .wr_en(wr_en),
        .data_out(data_out),
        .sync_data_ready(sync_data_ready)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Clock period of 10ns
    end

    // Test procedure
    initial begin
        // Initialize inputs
        rst_n = 0;
        data_in = 64'b0;
        wr_en = 0;

        // Reset the system
        #10 rst_n = 1;

        // Test case 1: Write data on both rising and falling edges
        #10 wr_en = 1;
        data_in = 64'hAAAAAAAAAAAAAAAA;  // Input data on rising edge
        #10 data_in = 64'h5555555555555555;  // Input data on falling edge
        
        // Wait for a cycle to observe the output
        #20;
        if (sync_data_ready)
            $display("Output data: %h (Expected: AAAAAAAA55555555)", data_out);
        else
            $display("Data not ready");

        // Test case 2: Reset the system and write new data
        #10 rst_n = 0;
        #10 rst_n = 1;
        data_in = 64'h123456789ABCDEF0;  // Input new data on rising edge
        #10 data_in = 64'h0FEDCBA987654321;  // Input new data on falling edge
        
        // Wait and check the output
        #20;
        if (sync_data_ready)
            $display("Output data: %h (Expected: 123456780FEDCBA9)", data_out);
        else
            $display("Data not ready");

        // End simulation
        #50;
        $finish;
    end

endmodule
