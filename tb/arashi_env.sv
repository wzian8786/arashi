class arashi_env extends uvm_env;
    `uvm_component_utils(arashi_env)

    arashi_agent agent;
    arashi_scoreboard sb;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent    = arashi_agent::type_id::create(.name("arashi_agent"), .parent(this));
        sb       = arashi_scoreboard::type_id::create(.name("arashi_sb"), .parent(this));
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.write_ap.connect(sb.write_export);
        agent.read_ap.connect(sb.read_export);
    endfunction: connect_phase
endclass: arashi_env

