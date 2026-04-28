class axi_lite_agent extends uvm_agent;

    `uvm_component_utils(axi_lite_agent)

    uvm_sequencer #(axi_lite_seq_item)     seqr;
    axi_lite_driver                        drv;
    axi_lite_monitor                       mon;
    uvm_analysis_port #(axi_lite_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seqr = uvm_sequencer#(axi_lite_seq_item)::type_id::create("seqr", this);
        drv  = axi_lite_driver::type_id::create("drv", this);
        mon  = axi_lite_monitor::type_id::create("mon", this);
        ap   = new("ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
        mon.ap.connect(ap);
    endfunction

endclass