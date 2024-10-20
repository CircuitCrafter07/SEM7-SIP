module tb_nvme_controller;

    // Inputs
    reg [127:0] pcie_rx_data;
    reg pcie_rx_valid;
    reg [31:0] ssd_data_in;

    // Outputs
    wire [31:0] ssd_data_out;
    wire ssd_write_enable;
    wire ssd_read_enable;
    wire [127:0] pcie_tx_data;
    wire pcie_tx_valid;

    // Instantiate the Unit Under Test (UUT)
    nvme_controller uut (
        .pcie_rx_data(pcie_rx_data),
        .pcie_rx_valid(pcie_rx_valid),
        .ssd_data_in(ssd_data_in),
        .ssd_data_out(ssd_data_out),
        .ssd_write_enable(ssd_write_enable),
        .ssd_read_enable(ssd_read_enable),
        .pcie_tx_data(pcie_tx_data),
        .pcie_tx_valid(pcie_tx_valid)
    );

    // Test procedure
    initial begin
        // Initialize inputs
        pcie_rx_data = 128'b0;
        pcie_rx_valid = 0;
        ssd_data_in = 32'b0;

        // Test case 1: NVMe Write Operation
        #10;
        pcie_rx_data = {32'hA5A5A5A5, 32'h00000001, 32'h00000000, 8'h02}; // Write command, addr = 1, data = A5A5A5A5
        pcie_rx_valid = 1;
        #10;
        pcie_rx_valid = 0;

        // Check SSD write enable and data
        #10;
        if (ssd_write_enable && ssd_data_out == 32'hA5A5A5A5) begin
            $display("Write operation passed! SSD data out = %h", ssd_data_out);
        end else begin
            $display("Write operation failed! SSD data out = %h", ssd_data_out);
        end

        // Test case 2: NVMe Read Operation
        #10;
        ssd_data_in = 32'h5A5A5A5A; // Simulate SSD read data
        pcie_rx_data = {32'b0, 32'h00000001, 32'b0, 8'h01}; // Read command, addr = 1
        pcie_rx_valid = 1;
        #10;
        pcie_rx_valid = 0;

        // Check PCIe TX data
        #10;
        if (pcie_tx_valid && pcie_tx_data[127:96] == 32'h5A5A5A5A) begin
            $display("Read operation passed! PCIe TX data = %h", pcie_tx_data[127:96]);
        end else begin
            $display("Read operation failed! PCIe TX data = %h", pcie_tx_data[127:96]);
        end

        // End simulation
        #50;
        $finish;
    end

endmodule
