class arashi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(arashi_scoreboard)

    uvm_analysis_export # (arashi_transaction) write_export;
    uvm_analysis_export # (arashi_transaction) read_export;
    uvm_tlm_analysis_fifo #(arashi_transaction) write_fifo;
    uvm_tlm_analysis_fifo #(arashi_transaction) read_fifo;

    arashi_transaction write_transaction;
    arashi_transaction read_transaction;

    virtual arashi_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        write_transaction = new("write_transaction");
        read_transaction = new("read_transaction");
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        void'(uvm_resource_db#(virtual arashi_if)::read_by_name
            (.scope("ifs"), .name("arashi_if"), .val(vif)));

        write_export = new("write_export", this);
        read_export = new("read_export", this);
        write_fifo = new("write_fifo", this);
        read_fifo = new("read_fifo", this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        write_export.connect(write_fifo.analysis_export);
        read_export.connect(read_fifo.analysis_export);
    endfunction: connect_phase

    task run();
        integer todo = 0; 
        integer rcount = 0;
        integer wcount = 0;
        integer tolerance = 0;

        integer data_map[bit [`DATA_WIDTH-1:0]]; 

        void'(uvm_config_db # (integer)::get
            (.cntxt(null), .inst_name("arashi_tb"), .field_name("tx_num"), .value(todo)));

        forever begin
            @(posedge vif.clk) begin
                tolerance++;
                for (integer i = 0; i < `THREAD_NUM; ++i) begin
                    if (write_fifo.try_get(write_transaction)) begin
                        tolerance = 0;
                        data_map[write_transaction.data_in]++;
                        wcount++;
                        if (!(wcount % 1000)) begin
                            `uvm_info("SB", $sformatf("[%0d/%0d] writing monitored.", wcount, todo), UVM_LOW);
                        end
                    end
                end
                if (read_fifo.try_get(read_transaction)) begin
                    tolerance = 0;
                    if (!data_map.exists(read_transaction.data_in) ||
                         data_map[read_transaction.data_in] == 0) begin
                        `uvm_fatal("SB", $sformatf("Unexpected data %0h", read_transaction.data_in));
                    end
                    else begin
                        data_map[read_transaction.data_in]--;
                    end
                    rcount++;
                    if (!(rcount % 1000)) begin
                        `uvm_info("SB", $sformatf("[%0d/%0d] reading monitored.", rcount, todo), UVM_LOW);
                    end
                end

                if (tolerance >= 100) begin
                    `uvm_fatal("SB", "No data monitored in 100 cycles");
                end

                if (rcount == todo) begin
                    bit [`DATA_WIDTH-1:0] key;
                    if (!data_map.first(key) || data_map[key] != 0) begin
                        `uvm_fatal("SB", "reading is missing");
                    end
                    while (data_map.next(key)) begin
                        if (data_map[key] != 0) begin
                            `uvm_fatal("SB", "reading is missing");
                        end
                    end
                    `uvm_info("SB", "PASS!", UVM_LOW);
                    $finish();
                end
            end
        end
    endtask: run
endclass: arashi_scoreboard
