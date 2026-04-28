class axi_lite_driver extends uvm_driver #(axi_lite_seq_item);

    `uvm_component_utils(axi_lite_driver)

    virtual axi_if axi_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_if)::get(this, "", "axi_vif", axi_vif)) begin
            `uvm_fatal("AXI_IF_NOT_FOUND", "Virtual interface not found in configuration database")
        end
    endfunction

    task run_phase(uvm_phase phase);
        axi_lite_seq_item req;
        forever begin
            seq_item_port.get_next_item(req);
            `uvm_info("AXI_DRV", req.convert2string(), UVM_MEDIUM);
            if (req.we) begin
                // Perform AXI Lite write transaction
                axi_vif.write(req.addr, req.data);
            end else begin
                // Perform AXI Lite read transaction
                axi_vif.read(req.addr, req.data);
            end
            seq_item_port.item_done();
        end
    endtask
endclass