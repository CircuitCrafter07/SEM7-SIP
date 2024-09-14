module ssd (
    input wire clk,               // System clock
    input wire reset_n,           // Active-low reset
    input wire [31:0] addr,       // Address from host for read/write
    input wire [31:0] data_in,    // Data from host for write operation
    input wire read_enable,       // Read enable signal from host
    input wire write_enable,      // Write enable signal from host
    output reg [31:0] data_out,   // Data to host for read operation
    output reg ready              // Ready signal to host
);

    // Define a memory block to represent SSD storage (using a 1024x32 memory array)
    reg [31:0] ssd_memory [1023:0];   // SSD storage memory block (32-bit data, 1024 locations)
    reg [31:0] ssd_read_data;         // Internal signal for read data

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Reset the controller
            ready <= 1'b0;
            data_out <= 32'd0;
            ssd_read_data <= 32'd0;
        end else begin
            // Initialize ready signal to 0
            ready <= 1'b0;
            
            // Write Operation
            if (write_enable) begin
                ssd_memory[addr] <= data_in;  // Write data to the SSD memory
                ready <= 1'b1;                // Indicate operation is complete
            end

            // Read Operation
            if (read_enable) begin
                ssd_read_data <= ssd_memory[addr]; // Read data from SSD memory
                data_out <= ssd_read_data;         // Send data back to host
                ready <= 1'b1;                     // Indicate operation is complete
            end
        end
    end

endmodule
