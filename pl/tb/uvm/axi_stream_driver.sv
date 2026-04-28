class axi_stream_driver extends uvm_driver #(axi_stream_seq_item);

    `uvm_component_utils(axi_stream_driver)

    virtual axi_if axi_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_if)::get(this, "", "axi_vif", axi_vif))
            `uvm_fatal("AXI_IF_NOT_FOUND", "Virtual interface not found in configuration database")
    endfunction

    task run_phase(uvm_phase phase);
        axi_stream_seq_item req;
        forever begin
            seq_item_port.get_next_item(req);
            `uvm_info("AXIS_DRV", req.convert2string(), UVM_MEDIUM)
            axi_vif.stream_send(req.tdata, req.tkeep, req.tlast);
            seq_item_port.item_done();
        end
    endtask

endclass
