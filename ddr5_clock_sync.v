module ddr5_clock_sync (
    input wire clk,             // System clock
    input wire rst_n,           // Active-low reset
    input wire [63:0] data_in,  // 64-bit input data
    input wire wr_en,           // Write enable signal
    output reg [63:0] data_out, // 64-bit output data
    output reg sync_data_ready  // Data ready signal
);

    reg [63:0] data_rise;       // Data captured on rising edge
    reg [63:0] data_fall;       // Data captured on falling edge
    reg data_ready;             // Data ready flag

    // Capture data on the rising edge of the system clock
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_rise <= 64'b0;
        end else if (wr_en) begin
            data_rise <= data_in;  // Capture input data
        end
    end

    // Capture data on the falling edge of the system clock
    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_fall <= 64'b0;
            data_ready <= 1'b0;
        end else if (wr_en) begin
            data_fall <= data_in;  // Capture input data
            data_ready <= 1'b1;    // Indicate that data is ready
        end else begin
            data_ready <= 1'b0;    // Reset data ready flag
        end
    end

    // Output data combination process
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 64'b0;
            sync_data_ready <= 1'b0;
        end else if (data_ready) begin
            data_out <= {data_fall[31:0], data_rise[63:32]};  // Combine captured data
            sync_data_ready <= 1'b1;                          // Assert data ready
        end else begin
            sync_data_ready <= 1'b0;                          // Deassert data ready
        end
    end

endmodule
