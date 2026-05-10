class axi4_lite_vseq extends dp_vseq_base;

    `uvm_object_utils(axi4_lite_vseq)

    function new(string name = "axi4_lite_vseq");
        super.new(name);
    endfunction

    task body();
        logic [31:0] rdata;

        #10ns;
        // Enable dataplane
        axi4_write(`DP_CTRL, 32'h1);

        #10ns;

        // Pattern avoids self-clearing bits: bit 2 (flow_table_flush), bit 9 (stats_clear)
        axi4_write(`DP_CTRL, 32'hA8A8A8A8);
        axi4_read(`DP_CTRL, rdata);

        if (rdata !== 32'hA8A8A8A8) `uvm_error("AXI4_LITE_TEST", $sformatf("Data mismatch: expected 0xA8A8A8A8, got 0x%08X", rdata))
        else `uvm_info("AXI4_LITE_TEST", $sformatf("Data match successful: 0x%08X", rdata), UVM_LOW)
    endtask

endclass

class axi4_lite_test extends dp_test_base;
    `uvm_component_utils(axi4_lite_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_test_body(uvm_phase phase);
        axi4_lite_vseq vseq = axi4_lite_vseq::type_id::create("vseq");
        vseq.axi_lite_seqr = env.axi_agent.seqr;
        vseq.start(null);
    endtask

endclass
