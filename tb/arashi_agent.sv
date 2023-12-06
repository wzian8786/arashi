class arashi_agent extends uvm_agent;
    typedef uvm_sequencer # (arashi_transaction) arashi_sequencer;
    `uvm_component_utils(arashi_agent)

    uvm_analysis_port # (arashi_transaction) write_ap;
    uvm_analysis_port # (arashi_transaction) read_ap;

    arashi_sequencer          seqr;
    arashi_driver             drvr;
    arashi_monitor            mon;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        write_ap = new(.name("write_ap"), .parent(this));
        read_ap = new(.name("read_ap"), .parent(this));

        seqr        = arashi_sequencer::type_id::create(.name("arashi_seqr"), .parent(this));
        drvr        = arashi_driver::type_id::create(.name("arshi_drvr"), .parent(this));
        mon         = arashi_monitor::type_id::create(.name("arashi_mon"), .parent(this));
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        drvr.seq_item_port.connect(seqr.seq_item_export);
        mon.write_ap.connect(write_ap);
        mon.read_ap.connect(read_ap);
    endfunction: connect_phase
endclass: arashi_agent
