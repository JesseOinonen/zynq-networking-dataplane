class dp_test_base extends uvm_test;

    `uvm_component_utils(dp_test_base)

    dp_env         env;
    virtual axi_if axi_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_if)::get(this, "", "axi_vif", axi_vif))
            `uvm_fatal("VIF_NOT_FOUND", "Virtual interface not found in config db")
        uvm_config_db#(virtual axi_if)::set(this, "env.axi_agent.*",    "axi_vif", axi_vif);
        uvm_config_db#(virtual axi_if)::set(this, "env.stream_agent.*", "axi_vif", axi_vif);
        env = dp_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        run_test_body(phase);
        phase.drop_objection(this);
    endtask

    virtual task run_test_body(uvm_phase phase);
    endtask

endclass
