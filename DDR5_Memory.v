module DDR5_Memory (
    input wire clk,             // Clock signal
    input wire rst_n,           // Active-low reset
    input wire [ADDR_WIDTH-1:0] addr,  // Address bus
    input wire [DATA_WIDTH-1:0] wr_data, // Write data bus
    input wire rd_en,           // Read enable
    input wire wr_en,           // Write enable
    output reg [DATA_WIDTH-1:0] rd_data  // Read data bus
);

    parameter ADDR_WIDTH = 16;  // Example address width
    parameter DATA_WIDTH = 64;  // Example data width
    parameter MEM_DEPTH = 1 << ADDR_WIDTH; // Memory depth (based on address width)

    // Memory array
    reg [DATA_WIDTH-1:0] memory_array [0:MEM_DEPTH-1];

    // Internal signals for double data rate operation
    reg [DATA_WIDTH/2-1:0] data_latch_1;
    reg [DATA_WIDTH/2-1:0] data_latch_2;

    // Double Data Rate Write Operation on Rising Edge
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset logic
            data_latch_1 <= 0;
        end else if (wr_en) begin
            // First write (lower half) on rising edge
            data_latch_1 <= wr_data[DATA_WIDTH/2-1:0];
        end
    end

    // Double Data Rate Write Operation on Falling Edge
    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset logic
            data_latch_2 <= 0;
        end else if (wr_en) begin
            // Second write (upper half) on falling edge
            data_latch_2 <= wr_data[DATA_WIDTH-1:DATA_WIDTH/2];
            // Store to memory on the falling edge
            memory_array[addr] <= {data_latch_2, data_latch_1};  // Combine both parts
        end
    end

    // Double Data Rate Read Operation on Rising Edge
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset logic
            rd_data <= 0;
        end else if (rd_en) begin
            // Read data from memory on the rising edge
            rd_data <= memory_array[addr];
        end
    end

endmodule
