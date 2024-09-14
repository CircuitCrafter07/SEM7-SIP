module sense_amplifier (
    input wire bitline,            // Input bitline (signal from memory cell)
    input wire bitline_bar,        // Complement of bitline (for differential sensing)
    input wire enable,             // Enable signal for sense amplifier
    output reg out                 // Amplified output signal
);

    always @(*) begin
        if (enable) begin
            // Differential sensing: if bitline > bitline_bar, output is 1, else 0
            if (bitline > bitline_bar)
                out = 1'b1;
            else
                out = 1'b0;
        end else begin
            out = 1'bz;  // High impedance when the sense amplifier is disabled
        end
    end

endmodule
