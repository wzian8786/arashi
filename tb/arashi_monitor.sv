class arashi_monitor extends uvm_monitor;
    `uvm_component_utils(arashi_monitor)

    uvm_analysis_port # (arashi_transaction) write_ap;
    uvm_analysis_port # (arashi_transaction) read_ap;

    virtual arashi_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        void'(uvm_resource_db#(virtual arashi_if)::read_by_name
            (.scope("ifs"), .name("arashi_if"), .val(vif)));
        write_ap = new(.name("write_ap"), .parent(this));
        read_ap = new(.name("read_ap"), .parent(this));
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        logic [`DATA_WIDTH-1:0] data[`THREAD_NUM];
        logic [`DATA_WIDTH*`THREAD_NUM-1:0] data_in;
        logic [`DATA_WIDTH*`THREAD_NUM-1:0] data_out;
        logic [`THREAD_NUM-1:0] w_ena = 0;
        logic [`THREAD_NUM-1:0] w_id = 0;
        logic [`THREAD_NUM-1:0] last_id = 0;
        logic [`THREAD_NUM-1:0] w_ready = 0;
        logic [`THREAD_NUM-1:0] r_ready = 0;
        logic [`THREAD_NUM*4-1:0] ctrl = 0;

        for (integer i = 0; i < `THREAD_NUM; ++i) begin
            data[i] = 0;
        end

        forever begin
            @(posedge vif.clk)
            begin
                if (vif.rstn) begin
                    w_ready = vif.w_ready;
                    r_ready = vif.r_ready;
                    data_in = vif.data_in;
                    data_out = vif.data_out;
                    ctrl    = vif.ctrl;
                    for (integer i = 0; i < `THREAD_NUM; ++i) begin
                        data[i] = data_in & 32'hffffffff;
                        data_in >>= `DATA_WIDTH;
                        w_ena[i] = (ctrl & 2'b10) >> 1;
                        if (w_ena[i]) begin
                            w_id[i]  = (ctrl & 4'b1000) >> 3;
                            if (w_id[i] != last_id[i]) begin
                                arashi_transaction tx;
                                tx = arashi_transaction::type_id::create
                                    (.name("arashi_tx"), .contxt(get_full_name()));
                                tx.ctrl = 1'b1;
                                tx.data_in = data[i];
                                write_ap.write(tx);
                                //`uvm_info("WRITE", $sformatf("data: %0h", tx.data_in), UVM_LOW);
                            end
                            last_id[i] = w_id[i];
                        end
                        ctrl >>= 4;

                        if (r_ready[i]) begin
                            arashi_transaction tx;
                            tx = arashi_transaction::type_id::create
                                (.name("arashi_tx"), .contxt(get_full_name()));
                            tx.ctrl = 1'b1;
                            tx.data_in = data_out >> (i * `DATA_WIDTH);
                            //`uvm_info("READ", $sformatf("data: %0h", tx.data_in), UVM_LOW);
                            read_ap.write(tx);
                        end
                    end
                end
            end
        end
    endtask: run_phase
endclass: arashi_monitor
