package axi_rx_testcase_pkg;
    `include "../top/register.svh"

    task axi_rx_testcase(input virtual axi_if axi);
        
        $display("Running axi_rx_testcase...");
        // Ethernet Frame:
            // Destination MAC: DA:02:03:04:05:06
            // Source MAC:      5A:02:03:04:05:06
            // Ethertype:       0x0800 (IPv4)
        // IPV4 Header:
            // Version: 4, IHL: 5
            // Total Length: 40 bytes (00 28)
            // TTL: 64 (40)
            // Protocol: TCP (06)
            // Source IP: C0.A8.01.01
            // Destination IP: C0.A8.01.02
        // TCP Header:
            // Source Port: 1234 (04D2)
            // Destination Port: 80 (0050)
            // Seq: 00 00 00 01
            // Ack: 00 00 00 00
            // Flags: SYN (50 02)
            // Window Size: 7210 (72 10)
        axi.stream_send(64'h025A0605040302DA, 8'hFF, 0);
        axi.stream_send(64'h0045000806050403, 8'hFF, 0);
        axi.stream_send(64'h0640004012342800, 8'hFF, 0);
        axi.stream_send(64'hA8C00101A8C00000, 8'hFF, 0);
        axi.stream_send(64'h00005000D2040201, 8'hFF, 0);
        axi.stream_send(64'h0250000000000100, 8'hFF, 0);
        axi.stream_send(64'h0000000000001072, 8'b0011_1111, 1);

        #10ns;

        // Read from CSR to verify packet reception
        logic [31:0] read_data;
        axi.read(`CSR_DST_MAC, read_data);
        if (read_data !== 32'hDA0203040506) $error("DST MAC mismatch: expected DA:02:03:04:05:06, got 0x%08X", read_data);
        axi.read(`CSR_SRC_MAC, read_data);
        if (read_data !== 32'h5A0203040506) $error("SRC MAC mismatch: expected 5A:02:03:04:05:06, got 0x%08X", read_data);
        
    endtask

endpackage