class arashi_driver extends uvm_driver # (arashi_transaction);
    `uvm_component_utils(arashi_driver)

    virtual arashi_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        void'(uvm_resource_db#(virtual arashi_if)::read_by_name
            (.scope("ifs"), .name("arashi_if"), .val(vif)));
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        drive();
    endtask: run_phase

    virtual task drive();
        arashi_transaction tx;
        logic [`THREAD_NUM-1:0] wr = 0;
        logic [`THREAD_NUM-1:0] w_id = 0;
        logic [`DATA_WIDTH-1:0] data[`THREAD_NUM];
        logic [`DATA_WIDTH*`THREAD_NUM-1:0] data_in = 0;
        logic [`DATA_WIDTH*2-1:0] ctrl;
        logic [`THREAD_NUM-1:0] w_ready;
        logic [`THREAD_NUM-1:0] rd = 0;

        integer todo = 0; 
        integer count = 0;

        for (integer i = 0; i < `THREAD_NUM; ++i) begin
            data[i] = 0;
        end 

        void'(uvm_config_db # (integer)::get
            (.cntxt(null), .inst_name("arashi_tb"), .field_name("tx_num"), .value(todo)));

        forever begin
            @(posedge vif.clk)
            begin
                if (vif.rstn) begin
                    w_ready = vif.w_ready;
                    for (integer i = 0; i < `THREAD_NUM; ++i) begin
                        if (!wr[i]) begin
                            seq_item_port.get_next_item(tx);
                            seq_item_port.item_done();
                            if (tx.ctrl && (count < todo)) begin
                                wr[i] = 1'b1;
                                w_id[i] = ~w_id[i];
                                data[i] = tx.data_in;
                                count++;
                            end
                            else begin
                                wr[i] = 1'b0;
                                data[i] = 0;
                            end
                        end
                        else begin
                            if (w_ready[i]) begin
                                wr[i] = 1'b0;
                                data[i] = 0;
                            end
                        end
                    end
                    for (integer i = 0; i < `THREAD_NUM; ++i) begin
                        if (!rd[i]) begin
                            seq_item_port.get_next_item(tx);
                            seq_item_port.item_done();
                            if (tx.ctrl) begin
                                rd[i] = 1'b1;
                            end
                            else begin
                                rd[i] = 1'b0;
                            end
                        end
                    end
                end

                data_in = 0;
                ctrl = 0;
                for (integer i = 0; i < `THREAD_NUM; ++i) begin
                    data_in <<= `DATA_WIDTH;
                    data_in |= data[`THREAD_NUM-i-1];
                    ctrl <<= 4; 
                    ctrl |= (rd[`THREAD_NUM-i-1]);
                    ctrl |= (wr[`THREAD_NUM-i-1] << 1);
                    ctrl |= ((wr[`THREAD_NUM-i-1] & w_id[`THREAD_NUM-i-1]) << 3);
                end
                vif.ctrl <= ctrl;
                vif.data_in <= data_in;

                if (count == todo) begin
                    `uvm_info("DRIVER", "No more writing generated.", UVM_LOW);
                    count++;
                end
            end
        end

        @(posedge vif.clk) begin
            vif.ctrl <= 0;
            vif.data_in <= 0;
        end
    endtask: drive
endclass: arashi_driver

