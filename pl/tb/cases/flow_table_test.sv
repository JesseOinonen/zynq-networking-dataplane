class flow_table_vseq extends dp_vseq_base;

    `uvm_object_utils(flow_table_vseq)

    function new(string name = "flow_table_vseq");
        super.new(name);
    endfunction

    local task write_csr(logic [31:0] addr, logic [31:0] data);
        axi_lite_write_seq wr_seq;
        wr_seq      = axi_lite_write_seq::type_id::create("wr_seq");
        wr_seq.addr = addr;
        wr_seq.data = data;
        wr_seq.start(axi_lite_seqr);
    endtask

    task body();
        parser_seq pkt_seq;

        #10ns;

        write_csr(`CSR_FLOW_TABLE_WDATA, 32'hD2005006);
        write_csr(`CSR_FLOW_TABLE_WDATA, 32'hA8010204);
        write_csr(`CSR_FLOW_TABLE_WDATA, 32'hA80101C0);
        write_csr(`CSR_FLOW_TABLE_WDATA, 32'h000000C0);
        write_csr(`CSR_FLOW_TABLE_WDATA, 32'h466);

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
