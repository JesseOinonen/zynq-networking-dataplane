package flow_table_testcase_pkg;
    `include "../top/register.svh"

    task flow_table_testcase(input virtual axi_if axi, output int passed, output int total);

        $display("Running flow_table_testcase...");

        #10ns;

        total++;

        // src_ip_capt   = C0.A8.01.01
        // dst_ip_capt   = C0.A8.01.02
        // src_port_capt = 04D2
        // dst_port_capt = 0050
        // protocol_capt = 06
        // flow_key = 128'h000000C0A80101C0A8010204D2005006
        // Write flow key to flow table and flow_id = 0x66 with valid bit set to 1
        axi.write(32'h8000A00C, 32'hD2005006); // flow_key[31:0]
        axi.write(32'h8000A00C, 32'hA8010204); // flow_key[63:32]
        axi.write(32'h8000A00C, 32'hA80101C0); // flow_key[95:64]
        axi.write(32'h8000A00C, 32'h000000C0); // flow_key[127:96]
        axi.write(32'h8000A00C, 32'h466);      // flow_id = 0x66, valid bit = 1

        // Send HEADER 1
        axi.stream_send(64'h025A0605040302DA, 8'hFF, 0);
        axi.stream_send(64'h0045000806050403, 8'hFF, 0);
        axi.stream_send(64'h0640004012342800, 8'hFF, 0);
        axi.stream_send(64'hA8C00101A8C00000, 8'hFF, 0);
        axi.stream_send(64'h00005000D2040201, 8'hFF, 0);
        axi.stream_send(64'h0250000000000100, 8'hFF, 0);
        axi.stream_send(64'h0000000000001072, 8'b0011_1111, 0);
        // Send PAYLOAD
        axi.stream_send(64'hAAAAAAAAAAAAAAAA, 8'hFF, 0);
        axi.stream_send(64'hBBBBBBBBBBBBBBBB, 8'hFF, 0);
        axi.stream_send(64'hCCCCCCCCCCCCCCCC, 8'hFF, 0);
        axi.stream_send(64'hDDDDDDDDDDDDDDDD, 8'hFF, 0);
        axi.stream_send(64'hEEEEEEEEEEEEEEEE, 8'hFF, 0);
        axi.stream_send(64'hFFFFFFFFFFFFFFFF, 8'hFF, 1);
        
        #1us;

        passed++;

        // Flow table should have flow_id = 0x66 and valid bit = 1 with flow key = 128'h000000C0A80101C0A8010204D2005006
        $display("Completed flow_table_testcase.");
    endtask

endpackage