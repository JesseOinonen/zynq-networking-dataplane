package flow_key_gen_testcase_pkg;
    `include "../top/register.svh"

    //-----------------------------------------
    // Flow Key Generation Testcase
    // Verify that the flow key is generated correctly based on the input packet headers
    // Send a packet with known headers and verify the flow key registers are populated with expected values
    //-----------------------------------------
    task flow_key_gen_testcase(input virtual axi_if axi, output int passed, output int total);
        logic [31:0] read_data;

        $display("Running flow_key_gen_testcase...");

        #10ns;

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

        #50ns;
        
        axi.read(`CSR_FLOW_KEY_32, read_data);
        if (read_data !== 32'hD2005006) begin
            $error("CSR_FLOW_KEY_32 mismatch: expected 0xD2005006, got 0x%08X", read_data);
        end 
        else begin
            $display("CSR_FLOW_KEY_32 match successful");
            passed++;
        end
        total++;

        axi.read(`CSR_FLOW_KEY_64, read_data);
        if (read_data !== 32'hA8010204) begin
            $error("CSR_FLOW_KEY_64 mismatch: expected 0xA8010204, got 0x%08X", read_data);
        end 
        else begin
            $display("CSR_FLOW_KEY_64 match successful");
            passed++;
        end
        total++;

        axi.read(`CSR_FLOW_KEY_96, read_data);
        if (read_data !== 32'hA80101C0) begin
            $error("CSR_FLOW_KEY_96 mismatch: expected 0xA80101C0, got 0x%08X", read_data);
        end 
        else begin
            $display("CSR_FLOW_KEY_96 match successful");
            passed++;
        end
        total++;

        axi.read(`CSR_FLOW_KEY_128, read_data);
        if (read_data !== 32'h000000C0) begin
            $error("CSR_FLOW_KEY_128 mismatch: expected 0x000000C0, got 0x%08X", read_data);
        end 
        else begin
            $display("CSR_FLOW_KEY_128 match successful");
            passed++;
        end
        total++;

        $display("Completed flow_key_gen_testcase.");
    endtask

endpackage
