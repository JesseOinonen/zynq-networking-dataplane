class axi_lite_monitor extends uvm_monitor;

    `uvm_component_utils(axi_lite_monitor)

    virtual axi_if axi_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    uvm_analysis_port #(axi_lite_seq_item) ap;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual axi_if)::get(this, "", "axi_vif", axi_vif)) begin
            `uvm_fatal("AXI_IF_NOT_FOUND", "Virtual interface not found in configuration database")
        end
    endfunction

    task run_phase(uvm_phase phase);
        fork
            monitor_write();
            monitor_read();
        join_none
    endtask

    task monitor_write();
        axi_lite_seq_item item;
        logic [31:0] wr_addr;
        forever begin
            @(posedge axi_vif.clk);
            if (axi_vif.AWVALID && axi_vif.AWREADY) begin
                wr_addr = axi_vif.AWADDR;
                while (!(axi_vif.WVALID && axi_vif.WREADY)) @(posedge axi_vif.clk);
                item      = axi_lite_seq_item::type_id::create("mon_wr");
                item.addr = wr_addr;
                item.data = axi_vif.WDATA;
                item.we   = 1;
                `uvm_info("AXI_MON", item.convert2string(), UVM_MEDIUM)
                ap.write(item);
            end
        end
    endtask

    task monitor_read();
        axi_lite_seq_item item;
        logic [31:0] rd_addr;
        forever begin
            @(posedge axi_vif.clk);
            if (axi_vif.ARVALID && axi_vif.ARREADY) begin
                rd_addr = axi_vif.ARADDR;
                while (!(axi_vif.RVALID && axi_vif.RREADY)) @(posedge axi_vif.clk);
                item      = axi_lite_seq_item::type_id::create("mon_rd");
                item.addr = rd_addr;
                item.data = axi_vif.RDATA;
                item.we   = 0;
                `uvm_info("AXI_MON", item.convert2string(), UVM_MEDIUM)
                ap.write(item);
            end
        end
    endtask

endclass