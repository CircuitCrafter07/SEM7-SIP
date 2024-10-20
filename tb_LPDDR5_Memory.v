module tb_LPDDR5_Memory;

    // Parameters
    localparam ADDR_WIDTH = 16;
    localparam DATA_WIDTH = 64;

    // Inputs
    reg clk;
    reg clk_en;
    reg rst_n;
    reg [ADDR_WIDTH-1:0] addr;
    reg [DATA_WIDTH-1:0] wr_data;
    reg rd_en;
    reg wr_en;

    // Outputs
    wire [DATA_WIDTH-1:0] rd_data;

    // Instantiate the Unit Under Test (UUT)
    LPDDR5_Memory #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk(clk),
        .clk_en(clk_en),
        .rst_n(rst_n),
        .addr(addr),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .rd_data(rd_data)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz clock (10ns period)
    end

    // Test procedure
    initial begin
        // Initialize inputs
        clk_en = 1;
        rst_n = 0;
        addr = 0;
        wr_data = 0;
        rd_en = 0;
        wr_en = 0;

        // Reset the system
        #10 rst_n = 1;

        // Test case 1: Write operation (DDR)
        #10 addr = 16'h0001;
        wr_data = 64'hAAAAAAAA55555555;  // Example data
        wr_en = 1;
        #10 wr_en = 0;

        // Test case 2: Read operation (DDR)
        #10 rd_en = 1;
        addr = 16'h0001;
        #10;
        rd_en = 0;

        // Check read data
        #10;
        if (rd_data == 64'hAAAAAAAA55555555) begin
            $display("Test Passed! Read data = %h", rd_data);
        end else begin
            $display("Test Failed! Read data = %h, Expected = %h", rd_data, 64'hAAAAAAAA55555555);
        end

        // Test case 3: Write new data
        #10 addr = 16'h0002;
        wr_data = 64'h123456789ABCDEF0;
        wr_en = 1;
        #10 wr_en = 0;

        // Test case 4: Read the new data
        #10 rd_en = 1;
        addr = 16'h0002;
        #10 rd_en = 0;

        // Check read data
        #10;
        if (rd_data == 64'h123456789ABCDEF0) begin
            $display("Test Passed! Read data = %h", rd_data);
        end else begin
            $display("Test Failed! Read data = %h, Expected = %h", rd_data, 64'h123456789ABCDEF0);
        end

        // End simulation
        #50;
        $finish;
    end

endmodule
