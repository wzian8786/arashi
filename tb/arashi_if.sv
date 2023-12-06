interface arashi_if;
    logic                                   clk;
    logic                                   rstn;
    logic   [`THREAD_NUM*4-1:0]             ctrl;
    logic   [`DATA_WIDTH*`THREAD_NUM-1:0]   data_in;
    logic   [`THREAD_NUM-1:0]               w_ready;
    logic   [`THREAD_NUM-1:0]               r_ready;
    logic   [`DATA_WIDTH*`THREAD_NUM-1:0]   data_out;
endinterface : arashi_if
