class axi_lite_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(axi_lite_scoreboard)

    uvm_analysis_imp #(axi_lite_seq_item, axi_lite_scoreboard) ap;

    logic [31:0] mem[*];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
    endfunction

    function void write(axi_lite_seq_item item);
        if (item.we) begin
            mem[item.addr] = item.data;
            `uvm_info("AXI_SCB", $sformatf("Stored: %s", item.convert2string()), UVM_MEDIUM)
        end else begin
            if (!mem.exists(item.addr))
                `uvm_error("AXI_SCB", $sformatf("Read from unknown addr 0x%08h", item.addr))
            else if (mem[item.addr] !== item.data)
                `uvm_error("AXI_SCB", $sformatf("MISMATCH addr=0x%08h exp=0x%08h got=0x%08h",
                            item.addr, mem[item.addr], item.data))
            else
                `uvm_info("AXI_SCB", $sformatf("MATCH: %s", item.convert2string()), UVM_MEDIUM)
        end
    endfunction

endclass