
package axi4_lite_testcase_pkg;
    `include "../top/register.svh"

    task axi4_lite_testcase(input virtual axi_if axi);
        logic [31:0] read_data;

        $display("Running axi4_lite_testcase...");
        
        axi.write(`CSR_CTRL, 32'hAAAAAAAA);

        #10ns;
        
        axi.read(`CSR_CTRL, read_data);
        if (read_data !== 32'hAAAAAAAA) begin
            $error("Data mismatch: expected 0xAAAAAAAA, got 0x%08X", read_data);
        end 
        else begin
            $display("Data match successful: 0x%08X", read_data);
        end
        $display("Completed axi4_lite_testcase.");
    endtask

endpackage