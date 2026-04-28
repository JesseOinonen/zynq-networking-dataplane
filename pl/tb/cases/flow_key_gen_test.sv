class flow_key_gen_vseq extends dp_vseq_base;

    `uvm_object_utils(flow_key_gen_vseq)

    function new(string name = "flow_key_gen_vseq");
        super.new(name);
    endfunction

    task body();
        parser_seq        pkt_seq;
        axi_lite_read_seq rd_seq;

        #10ns;

        pkt_seq = parser_seq::type_id::create("pkt_seq");
        pkt_seq.start(axi_stream_seqr);

        #50ns;

        rd_seq = axi_lite_read_seq::type_id::create("rd_seq");
        rd_seq.addr = `CSR_FLOW_KEY_32;
        rd_seq.start(axi_lite_seqr);
        if (rd_seq.data !== 32'hD2005006)
            `uvm_error("FLOW_KEY_TEST", $sformatf("CSR_FLOW_KEY_32 mismatch: expected 0xD2005006, got 0x%08X", rd_seq.data))
        else
            `uvm_info("FLOW_KEY_TEST", "CSR_FLOW_KEY_32 match successful", UVM_LOW)

        rd_seq = axi_lite_read_seq::type_id::create("rd_seq");
        rd_seq.addr = `CSR_FLOW_KEY_64;
        rd_seq.start(axi_lite_seqr);
        if (rd_seq.data !== 32'hA8010204)
            `uvm_error("FLOW_KEY_TEST", $sformatf("CSR_FLOW_KEY_64 mismatch: expected 0xA8010204, got 0x%08X", rd_seq.data))
        else
            `uvm_info("FLOW_KEY_TEST", "CSR_FLOW_KEY_64 match successful", UVM_LOW)

        rd_seq = axi_lite_read_seq::type_id::create("rd_seq");
        rd_seq.addr = `CSR_FLOW_KEY_96;
        rd_seq.start(axi_lite_seqr);
        if (rd_seq.data !== 32'hA80101C0)
            `uvm_error("FLOW_KEY_TEST", $sformatf("CSR_FLOW_KEY_96 mismatch: expected 0xA80101C0, got 0x%08X", rd_seq.data))
        else
            `uvm_info("FLOW_KEY_TEST", "CSR_FLOW_KEY_96 match successful", UVM_LOW)

        rd_seq = axi_lite_read_seq::type_id::create("rd_seq");
        rd_seq.addr = `CSR_FLOW_KEY_128;
        rd_seq.start(axi_lite_seqr);
        if (rd_seq.data !== 32'h000000C0)
            `uvm_error("FLOW_KEY_TEST", $sformatf("CSR_FLOW_KEY_128 mismatch: expected 0x000000C0, got 0x%08X", rd_seq.data))
        else
            `uvm_info("FLOW_KEY_TEST", "CSR_FLOW_KEY_128 match successful", UVM_LOW)
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
