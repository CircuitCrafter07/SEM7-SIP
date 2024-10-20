module LPDDR5_Memory(
    input wire clk,                     // Clock signal
    input wire rst_n,                   // Active-low reset
    input wire [15:0] addr,             // Address bus (16-bit width for 64K addresses)
    input wire [63:0] wr_data,          // Write data bus (64-bit data width)
    input wire rd_en,                   // Read enable
    input wire wr_en,                   // Write enable
    output reg [63:0] rd_data           // Read data bus
);

    // Define memory array with 16-bit addressable depth and 64-bit data width
    reg [63:0] memory_array [0:65535];

    // Internal latches for DDR write
    reg [31:0] data_latch_1;   // Lower half latched on rising edge
    reg [31:0] data_latch_2;   // Upper half latched on falling edge

    // Double Data Rate Write on Rising Edge
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_latch_1 <= 32'h00000000;
        end else if (wr_en) begin
            data_latch_1 <= wr_data[31:0];
        end
    end

    // Double Data Rate Write on Falling Edge
    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_latch_2 <= 32'h00000000;
        end else if (wr_en) begin
            data_latch_2 <= wr_data[63:32];
            memory_array[addr] <= {data_latch_2, data_latch_1};
        end
    end

    // Read Operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_data <= 64'h0000000000000000;
        end else if (rd_en) begin
            rd_data <= memory_array[addr];
        end
    end

endmodule
