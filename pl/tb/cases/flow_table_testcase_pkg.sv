package flow_table_testcase_pkg;
    `include "../top/register.svh"

    task flow_table_testcase(input virtual axi_if axi, output int passed, output int total);

        $display("Running flow_table_testcase...");

        #10ns;

        total++;
        // Write hash(flow_key) BRAM to test flow_table
        axi.write(32'h8000A00C, 32'hFFFFFFFF);
        axi.write(32'h8000A00C, 32'hFFFFFFFF);
        axi.write(32'h8000A00C, 32'hFFFFFFFF);
        axi.write(32'h8000A00C, 32'hFFFFFFFF);
        axi.write(32'h8000A00C, 32'hFFFFFFFF);
        passed++;

        $display("Completed flow_table_testcase.");
    endtask

endpackage