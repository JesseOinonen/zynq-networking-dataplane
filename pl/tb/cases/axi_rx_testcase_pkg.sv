package axi_rx_testcase_pkg;
    `include "../top/register.svh"

    task axi_rx_testcase(input virtual axi_if axi, input logic [47:0] dst_mac, input  logic [47:0] src_mac, input logic [15:0] eth_type);
        
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
        axi.stream_send(64'hDA02030405065A02, 8'hFF, 0);
        axi.stream_send(64'h0304050608004500, 8'hFF, 0);
        axi.stream_send(64'h0028123440004006, 8'hFF, 0);
        axi.stream_send(64'h0000C0A80101C0A8, 8'hFF, 0);
        axi.stream_send(64'h010204D200500000, 8'hFF, 0);
        axi.stream_send(64'h0001000000005002, 8'hFF, 0);
        axi.stream_send(64'h7210000000000000, 8'b1111_1100, 1);
        #10ns;
        
        if (dst_mac !== 48'hDA_02_03_04_05_06) begin
            $error("AXI RX Testcase Failed: Incorrect Destination MAC Address. Expected: %h, Received: %h", 48'hDA_02_03_04_05_06, dst_mac);
        end
        if (src_mac !== 48'h5A_02_03_04_05_06) begin
            $error("AXI RX Testcase Failed: Incorrect Source MAC Address. Expected: %h, Received: %h", 48'h5A_02_03_04_05_06, src_mac);
        end
        if (eth_type !== 16'h0800) begin
            $error("AXI RX Testcase Failed: Incorrect Ethertype. Expected: %h, Received: %h", 16'h0800, eth_type);
        end
        $display("Completed axi_rx_testcase.");
    endtask

endpackage