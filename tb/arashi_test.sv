class arashi_test extends uvm_test;
    `uvm_component_utils(arashi_test)

    arashi_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = arashi_env::type_id::create(.name("arashi_env"), .parent(this));
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        arashi_sequence seq;

        phase.raise_objection(.obj(this));
        seq = arashi_sequence::type_id::create(.name("arashi_seq"), .contxt(get_full_name()));
        //assert(seq.randomize());
        seq.start(env.agent.seqr);
        phase.drop_objection(.obj(this));
    endtask: run_phase
endclass: arashi_test
