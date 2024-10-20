module tb_sense_amplifier;

    // Inputs
    reg bitline;
    reg bitline_bar;
    reg enable;

    // Outputs
    wire out;

    // Instantiate the Unit Under Test (UUT)
    sense_amplifier uut (
        .bitline(bitline), 
        .bitline_bar(bitline_bar), 
        .enable(enable), 
        .out(out)
    );

    // Test procedure
    initial begin
        // Initial state
        bitline = 0;
        bitline_bar = 0;
        enable = 0;

        // Test case 1: Amplifier disabled, output should be high impedance
        #10;
        $display("Test Case 1: Amplifier disabled");
        enable = 0;
        bitline = 1;
        bitline_bar = 0;
        #10;
        $display("Output: %b (Expected: z)", out);

        // Test case 2: Amplifier enabled, bitline > bitline_bar
        #10;
        $display("Test Case 2: Amplifier enabled, bitline > bitline_bar");
        enable = 1;
        bitline = 1;
        bitline_bar = 0;
        #10;
        $display("Output: %b (Expected: 1)", out);

        // Test case 3: Amplifier enabled, bitline < bitline_bar
        #10;
        $display("Test Case 3: Amplifier enabled, bitline < bitline_bar");
        enable = 1;
        bitline = 0;
        bitline_bar = 1;
        #10;
        $display("Output: %b (Expected: 0)", out);

        // Test case 4: Amplifier enabled, bitline = bitline_bar
        #10;
        $display("Test Case 4: Amplifier enabled, bitline == bitline_bar");
        enable = 1;
        bitline = 0;
        bitline_bar = 0;
        #10;
        $display("Output: %b (Expected: 0)", out);

        // End simulation
        #10;
        $finish;
    end

endmodule
