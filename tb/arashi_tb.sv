`include "arashi_pkg.sv"
`include "arashi_if.sv"

module arashi_tb;
    import uvm_pkg::*;
    import arashi_pkg::*;

    // Interface declaration
    arashi_if vif();

    // Connects the Interface to the DUT
    arashi_top # (.DATA_WIDTH(`DATA_WIDTH),
                  .MEM_WIDTH(`MEM_WIDTH),
                  .THREAD_NUM_WIDTH(`THREAD_NUM_WIDTH))
             dut (.clk(vif.clk),
                  .rstn(vif.rstn),
                  .ctrl(vif.ctrl),
                  .data_in(vif.data_in),
                  .w_ready(vif.w_ready),
                  .r_ready(vif.r_ready),
                  .data_out(vif.data_out));

    initial begin
        // Registers the Interface in the configuration block so that other
        // blocks can use it
        uvm_resource_db # (virtual arashi_if)::set
            (.scope("ifs"), .name("arashi_if"), .val(vif));

        uvm_config_db # (integer)::set
            (.cntxt(null), .inst_name("arashi_tb"), .field_name("tx_num"), .value(10000));

        `uvm_info("TB", "Number of read/write 10000.", UVM_LOW);
        `uvm_info("TB", "Start running ...", UVM_LOW);

        //Executes the test
        run_test("arashi_test");
    end

    // Variable initialization
    initial begin
        $fsdbDumpfile("arashi.fsdb");
        $fsdbDumpvars(0, arashi_tb);

        vif.rstn = 1'b0;
        vif.clk  = 1'b0;

        #25;
        vif.rstn = 1'b1;

        #150000 $finish();
    end

    // Clock generation
    always
        #5 vif.clk = ~vif.clk;
endmodule
