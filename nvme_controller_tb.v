`timescale 1ns / 1ps

module nvme_controller_tb;

    // Clock and reset signals
    reg clk;
    reg rst_n;

    // Submission queue signals
    reg submission_write_enable;
    reg [63:0] submission_write_data;

    // Completion queue signals
    reg completion_read_enable;
    wire [63:0] completion_read_data;

    // Instantiate the NVMe controller
    nvme_controller uut (
        .clk(clk),
        .rst_n(rst_n),
        .submission_write_enable(submission_write_enable),
        .submission_write_data(submission_write_data),
        .completion_read_enable(completion_read_enable),
        .completion_read_data(completion_read_data)
    );

    // Clock generation
    always #5 clk = ~clk; // 10 ns clock period (100 MHz)

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        submission_write_enable = 0;
        submission_write_data = 64'd0;
        completion_read_enable = 0;

        // Apply reset
        #20;
        rst_n = 1;

        // Write a command to the submission queue (opcode 0x01 for write, LBA = 0x10, length = 0x04)
        #20;
        submission_write_data = {8'h01, 32'h00000010, 16'h0004, 8'h00}; // {opcode, LBA, length, padding}
        submission_write_enable = 1;
        #10;
        submission_write_enable = 0;

        // Wait for the write command to be processed
        #100;

        // Write a command to the submission queue (opcode 0x02 for read, LBA = 0x10, length = 0x04)
        submission_write_data = {8'h02, 32'h00000010, 16'h0004, 8'h00}; // {opcode, LBA, length, padding}
        submission_write_enable = 1;
        #10;
        submission_write_enable = 0;

        // Wait for the read command to be processed
        #100;

        // Read the completion queue
        completion_read_enable = 1;
        #10;
        completion_read_enable = 0;

        // Finish simulation
        #200;
        $finish;
    end

    // Monitor output signals
    initial begin
        $monitor("Time: %0t | Completion Queue Data: %h", $time, completion_read_data);
    end

endmodule
