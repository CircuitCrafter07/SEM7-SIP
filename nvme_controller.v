module nvme_controller(
    input wire [127:0] pcie_rx_data, // PCIe received data
    input wire pcie_rx_valid,        // PCIe data valid signal
    input wire [31:0] ssd_data_in,   // Data from SSD (for read operations)
    output wire [31:0] ssd_data_out, // Data to SSD (for write operations)
    output wire ssd_write_enable,    // SSD write enable signal
    output wire ssd_read_enable,     // SSD read enable signal
    output wire [127:0] pcie_tx_data,// PCIe transmitted data
    output wire pcie_tx_valid        // PCIe data valid for transmission
);

    // NVMe command opcodes (simplified)
    localparam [7:0] NVME_CMD_READ  = 8'h01;
    localparam [7:0] NVME_CMD_WRITE = 8'h02;

    // Extract fields from PCIe RX data (using data flow)
    wire [7:0] command_opcode   = pcie_rx_data[7:0];      // Command opcode
    wire [31:0] command_addr    = pcie_rx_data[63:32];    // Command address
    wire [31:0] command_data    = pcie_rx_data[127:96];   // Command data (for write operations)

    // Define the SSD operation control signals using data flow
    assign ssd_read_enable = (pcie_rx_valid && (command_opcode == NVME_CMD_READ)) ? 1'b1 : 1'b0;
    assign ssd_write_enable = (pcie_rx_valid && (command_opcode == NVME_CMD_WRITE)) ? 1'b1 : 1'b0;

    // Data to be written to the SSD (for write operations)
    assign ssd_data_out = (ssd_write_enable) ? command_data : 32'b0;

    // Data flow for PCIe TX data (response to the host)
    assign pcie_tx_data = (ssd_read_enable) ? {ssd_data_in, 96'b0} : 128'b0;

    // PCIe TX valid signal (only valid during read operations)
    assign pcie_tx_valid = (ssd_read_enable) ? 1'b1 : 1'b0;

endmodule
