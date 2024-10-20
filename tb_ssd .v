module tb_ssd;

    // Parameters
    reg clk;
    reg reset_n;
    reg [31:0] addr;
    reg [31:0] data_in;
    reg read_enable;
    reg write_enable;
    wire [31:0] data_out;
    wire ready;

    // Instantiate the SSD module
    ssd uut (
        .clk(clk),
        .reset_n(reset_n),
        .addr(addr),
        .data_in(data_in),
        .read_enable(read_enable),
        .write_enable(write_enable),
        .data_out(data_out),
        .ready(ready)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns clock period
    end

    // Test procedure
    initial begin
        // Initialize signals
        reset_n = 0;
        addr = 0;
        data_in = 0;
        read_enable = 0;
        write_enable = 0;

        // Apply reset
        #10;
        reset_n = 1; // Release reset
        #10;

        // Write to address 0
        addr = 32'd0;
        data_in = 32'hDEADBEEF; // Test data
        write_enable = 1;
        #10; // Wait one clock cycle
        write_enable = 0; // Disable write

        // Check if ready signal is high
        #10;
        if (ready) $display("Write operation complete at addr 0 with data: %h", data_in);
        else $display("Write operation not complete!");

        // Read from address 0
        addr = 32'd0;
        read_enable = 1;
        #10; // Wait one clock cycle
        read_enable = 0; // Disable read

        // Check output data
        #10;
        if (data_out == 32'hDEADBEEF) 
            $display("Read operation successful! Data: %h", data_out);
        else 
            $display("Read operation failed! Expected: %h, Got: %h", 32'hDEADBEEF, data_out);

        // Write to another address
        addr = 32'd1;
        data_in = 32'hCAFEBABE; // Test data
        write_enable = 1;
        #10; // Wait one clock cycle
        write_enable = 0; // Disable write

        // Read from address 1
        addr = 32'd1;
        read_enable = 1;
        #10; // Wait one clock cycle
        read_enable = 0; // Disable read

        // Check output data
        #10;
        if (data_out == 32'hCAFEBABE) 
            $display("Read operation successful! Data: %h", data_out);
        else 
            $display("Read operation failed! Expected: %h, Got: %h", 32'hCAFEBABE, data_out);

        // Finish simulation
        #10;
        $finish;
    end

endmodule
