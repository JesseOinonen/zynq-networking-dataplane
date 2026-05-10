class flow_table_vseq extends dp_vseq_base;

    `uvm_object_utils(flow_table_vseq)

    function new(string name = "flow_table_vseq");
        super.new(name);
    endfunction

    task body();
        parser_seq pkt_seq;

        #10ns;
        // Enable dataplane
        axi4_write(`DP_CTRL, 32'h1);

        #10ns;

        axi4_write(`CSR_FLOW_TABLE_WDATA, 32'hD2005006);
        axi4_write(`CSR_FLOW_TABLE_WDATA, 32'hA8010204);
        axi4_write(`CSR_FLOW_TABLE_WDATA, 32'hA80101C0);
        axi4_write(`CSR_FLOW_TABLE_WDATA, 32'h000000C0);
        axi4_write(`CSR_FLOW_TABLE_WDATA, 32'h466);

        pkt_seq = parser_seq::type_id::create("pkt_seq");
        pkt_seq.start(axi_stream_seqr);

        #1us;

        `uvm_info("FLOW_TABLE_TEST", "flow_table_testcase completed", UVM_LOW)
    endtask

endclass

class flow_table_test extends dp_test_base;
    `uvm_component_utils(flow_table_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_test_body(uvm_phase phase);
        flow_table_vseq vseq = flow_table_vseq::type_id::create("vseq");
        vseq.axi_lite_seqr   = env.axi_agent.seqr;
        vseq.axi_stream_seqr = env.stream_agent.seqr;
        vseq.start(null);
    endtask

endclass
