`timescale 1ns/1ps;
module arashi_top # (DATA_WIDTH = 32,
                     MEM_WIDTH  = 10,
                     THREAD_NUM = 4)
                    (clk,
                     rstn,
                     ctrl,
                     in,
                     out);
    // system clock
    input   wire                                    clk;
    // reset if 0
    input   wire                                    rstn;
    // ctrl signal bit 1 => write, bit 0 => read
    input   wire        [THREAD_NUM*2-1:0]          ctrl;
    // input data (write data)
    input   wire        [DATA_WIDTH*THREAD_NUM-1:0] in;
    // output data
    output  wire        [DATA_WIDTH*THREAD_NUM-1:0] out;

            // write enable
            wire        [THREAD_NUM-1:0]            wr;

            // read enable
            wire        [THREAD_NUM-1:0]            rd;

            // write address
            wire        [MEM_WIDTH*THREAD_NUM-1:0]  waddr;

    // decode read/write enable from ctrl signal
    generate
        genvar i;
        for (i = 0; i < THREAD_NUM; i++) begin
            arashi_ctrl_decoder decoder(.ctrl(ctrl[i*2+1:i*2]),
                                        .wr(wr[i]),
                                        .rd(rd[i]));
        end
    endgenerate

    generate
        if (THREAD_NUM >= 32) $error("Bad parameter THREAD_NUM=%d, it cannot be larger than 32", THREAD_NUM);
        if (THREAD_NUM % 4) $error("Bad parameter THREAD_NUM=%d, it must be a multiple of 4", THREAD_NUM);
    endgenerate

    // for each thread, determin the write address
    arashi_arbiter # (THREAD_NUM, MEM_WIDTH) warbiter(.clk(clk),
                                                      .rstn(rstn),
                                                      .wr(wr),
                                                      .maddr(waddr));

    // write data into memory
    arashi_mem # (DATA_WIDTH, MEM_WIDTH, THREAD_NUM) mem(.clk(clk),
                                                         .rstn(rstn),
                                                         .wr(wr),
                                                         .waddr(waddr),
                                                         .wdata(in));
endmodule
