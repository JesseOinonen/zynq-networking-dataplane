class flow_key_gen_vseq extends dp_vseq_base;

    `uvm_object_utils(flow_key_gen_vseq)

    function new(string name = "flow_key_gen_vseq");
        super.new(name);
    endfunction

    task body();
        parser_seq   pkt_seq;
        logic [31:0] rdata;

        #10ns;
        // Enable dataplane
        axi4_write(`DP_CTRL, 32'h1);

        #10ns;

        pkt_seq = parser_seq::type_id::create("pkt_seq");
        pkt_seq.start(axi_stream_seqr);

        #50ns;

        axi4_read(`CSR_FLOW_KEY_32, rdata);
        if (rdata !== 32'hD2005006) `uvm_error("FLOW_KEY_TEST", $sformatf("CSR_FLOW_KEY_32 mismatch: expected 0xD2005006, got 0x%08X", rdata))
        else `uvm_info("FLOW_KEY_TEST", "CSR_FLOW_KEY_32 match successful", UVM_LOW)

        axi4_read(`CSR_FLOW_KEY_64, rdata);
        if (rdata !== 32'hA8010204) `uvm_error("FLOW_KEY_TEST", $sformatf("CSR_FLOW_KEY_64 mismatch: expected 0xA8010204, got 0x%08X", rdata))
        else `uvm_info("FLOW_KEY_TEST", "CSR_FLOW_KEY_64 match successful", UVM_LOW)

        axi4_read(`CSR_FLOW_KEY_96, rdata);
        if (rdata !== 32'hA80101C0) `uvm_error("FLOW_KEY_TEST", $sformatf("CSR_FLOW_KEY_96 mismatch: expected 0xA80101C0, got 0x%08X", rdata))
        else `uvm_info("FLOW_KEY_TEST", "CSR_FLOW_KEY_96 match successful", UVM_LOW)

        axi4_read(`CSR_FLOW_KEY_128, rdata);
        if (rdata !== 32'h000800C0) `uvm_error("FLOW_KEY_TEST", $sformatf("CSR_FLOW_KEY_128 mismatch: expected 0x000800C0, got 0x%08X", rdata))
        else `uvm_info("FLOW_KEY_TEST", "CSR_FLOW_KEY_128 match successful", UVM_LOW)
    endtask

endclass

class flow_key_gen_test extends dp_test_base;
    `uvm_component_utils(flow_key_gen_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_test_body(uvm_phase phase);
        flow_key_gen_vseq vseq = flow_key_gen_vseq::type_id::create("vseq");
        vseq.axi_lite_seqr   = env.axi_agent.seqr;
        vseq.axi_stream_seqr = env.stream_agent.seqr;
        vseq.start(null);
    endtask

endclass
