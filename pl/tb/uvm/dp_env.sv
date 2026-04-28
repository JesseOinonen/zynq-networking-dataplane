class dp_env extends uvm_env;

    `uvm_component_utils(dp_env)

    axi_lite_agent      axi_agent;
    axi_stream_agent    stream_agent;
    axi_lite_scoreboard sb;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_agent    = axi_lite_agent::type_id::create("axi_agent", this);
        stream_agent = axi_stream_agent::type_id::create("stream_agent", this);
        sb           = axi_lite_scoreboard::type_id::create("sb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        axi_agent.ap.connect(sb.ap);
    endfunction

endclass
