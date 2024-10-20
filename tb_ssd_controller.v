module tb_ssd_controller;

    // Inputs
    reg clk;
    reg rst;
    reg [31:0] host_data_in;
    reg host_read;
    reg host_write;
    reg [31:0] flash_data_in;
    reg flash_read;
    reg flash_write;

    // Outputs
    wire [31:0] host_data_out;
    wire host_ready;
    wire [31:0] flash_data_out;
    wire flash_ready;

    // Instantiate the Unit Under Test (UUT)
    ssd_controller uut (
        .clk(clk),
        .rst(rst),
        .host_data_in(host_data_in),
        .host_data_out(host_data_out),
        .host_read(host_read),
        .host_write(host_write),
        .host_ready(host_ready),
        .flash_data_in(flash_data_in),
        .flash_data_out(flash_data_out),
        .flash_ready(flash_ready),
        .flash_read(flash_read),
        .flash_write(flash_write)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period of 10ns
    end

    // Test procedure
    initial begin
        // Initial values
        rst = 1;
        host_data_in = 32'd0;
        host_read = 0;
        host_write = 0;
        flash_data_in = 32'd0;
        flash_read = 0;
        flash_write = 0;

        // Reset the system
        #10 rst = 0;

        // Test case 1: Write data from host to SSD
        #10;
        host_data_in = 32'hA5A5A5A5;
        host_write = 1;
        #10;
        host_write = 0;
        
        // Wait for ready signal to confirm data is written
        #10;
        if (host_ready)
            $display("Host data written: %h", host_data_in);
        
        // Test case 2: Read data from flash memory to host
        #10;
        flash_data_in = 32'hDEADBEEF;
        flash_read = 1;
        #10;
        flash_read = 0;

        // Check the output from flash to host
        #10;
        if (flash_ready)
            $display("Flash data read: %h", flash_data_out);

        // Test case 3: ECC error detection and correction
        #10;
        host_data_in = 32'hFFFFFFFF; // Introduce data with an error
        host_write = 1;
        #10;
        host_write = 0;
        
        // Check if ECC detects and corrects the error
        #10;
        $display("Error detected: %b, Error corrected data: %h", uut.error_correction.error_detected, uut.error_correction.error_corrected);

        // End simulation
        #50;
        $finish;
    end

endmodule
