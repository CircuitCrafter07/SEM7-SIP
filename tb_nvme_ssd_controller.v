module tb_nvme_ssd_controller;

    reg clk;
    reg reset_n;

    // Host interface
    reg [31:0] addr;
    reg [31:0] data_in;
    reg read_enable;
    reg write_enable;
    wire [31:0] data_out;
    wire ready;

    // NVMe interface
    reg submission_write_enable;
    reg [63:0] submission_write_data;
    reg completion_read_enable;
    wire [63:0] completion_read_data;

    // Instantiate the DUT (Device Under Test)
    nvme_ssd_controller uut (
        .clk(clk),
        .reset_n(reset_n),
        .addr(addr),
        .data_in(data_in),
        .read_enable(read_enable),
        .write_enable(write_enable),
        .data_out(data_out),
        .ready(ready),
        .submission_write_enable(submission_write_enable),
        .submission_write_data(submission_write_data),
        .completion_read_enable(completion_read_enable),
        .completion_read_data(completion_read_data)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock period
    end

    // Testbench stimuli
    initial begin
        // Initialize inputs
        reset_n = 0;
        addr = 32'd0;
        data_in = 32'd0;
        read_enable = 0;
        write_enable = 0;
        submission_write_enable = 0;
        submission_write_data = 64'd0;
        completion_read_enable = 0;

        // Reset sequence
        #20 reset_n = 1;

        // Test write to SSD memory
        #10 addr = 32'd10; data_in = 32'hDEADBEEF; write_enable = 1;
        #10 write_enable = 0;

        // Test read from SSD memory
        #20 addr = 32'd10; read_enable = 1;
        #10 read_enable = 0;

        // Wait for the ready signal
        wait (ready);

        // Test submission of NVMe command
        #20 submission_write_enable = 1;
        submission_write_data = {16'd1, 32'd20, 8'h01};  // Write command
        #10 submission_write_enable = 0;

        // Wait for NAND completion and check completion queue
        #100 completion_read_enable = 1;
        #10 completion_read_enable = 0;

        // Check read operation from completion queue
        #50 submission_write_enable = 1;
        submission_write_data = {16'd1, 32'd30, 8'h02};  // Read command
        #10 submission_write_enable = 0;

        // Wait for NAND completion
        #100 completion_read_enable = 1;
        #10 completion_read_enable = 0;

        #100 $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time=%t, Reset=%b, Addr=%h, Data_in=%h, Read_enable=%b, Write_enable=%b, Data_out=%h, Ready=%b",
                 $time, reset_n, addr, data_in, read_enable, write_enable, data_out, ready);
    end

endmodule
