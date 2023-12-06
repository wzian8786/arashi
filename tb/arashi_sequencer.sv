class arashi_transaction extends uvm_sequence_item;
    rand bit                                ctrl;
    rand bit [`DATA_WIDTH-1:0]              data_in;

    function new(string name = "");
        super.new(name);
    endfunction: new 

    `uvm_object_utils_begin(arashi_transaction)
        `uvm_field_int(ctrl,        UVM_ALL_ON)
        `uvm_field_int(data_in,     UVM_ALL_ON)
    `uvm_object_utils_end
endclass: arashi_transaction

class arashi_sequence extends uvm_sequence # (arashi_transaction);
    `uvm_object_utils(arashi_sequence)

    function new(string name = "");
        super.new(name);
    endfunction: new 

    task body();
        arashi_transaction tx;

        forever begin
            tx = arashi_transaction::type_id::create(
                    .name("arashi_tx"), .contxt(get_full_name()));
            if (!tx.randomize()) assert(0);

            start_item(tx);
            //`uvm_info("sa_sequence", sa_tx.sprint(), UVM_LOW);
            finish_item(tx);
        end
    endtask: body
endclass: arashi_sequence

typedef uvm_sequencer # (arashi_transaction) arashi_sequencer;
