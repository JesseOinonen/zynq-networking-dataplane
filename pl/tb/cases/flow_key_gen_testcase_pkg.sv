package flow_key_gen_testcase_pkg;
    `include "../top/register.svh"

    task flow_key_gen_testcase(input virtual axi_if axi, output int passed, output int total);
        logic [31:0] read_data;

        $display("Running flow_key_gen_testcase...");

        #10ns;
        
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