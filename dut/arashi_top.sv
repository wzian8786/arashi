module arashi_top # (DATA_WIDTH = 32,
                     MEM_WIDTH  = 10,
                     THREAD_NUM_WIDTH = 2)
                    (clk,
                     rstn,
                     ctrl,
                     data_in,
                     w_ready,
                     r_ready,
                     data_out);

    localparam THREAD_NUM = 1 << THREAD_NUM_WIDTH;

    // system clock
    input   wire                                    clk;
    // reset if 0
    input   wire                                    rstn;
    // ctrl signal bit 1 => write, bit 0 => read
    input   wire        [THREAD_NUM*2-1:0]          ctrl;
    // input data (write data)
    input   wire        [DATA_WIDTH*THREAD_NUM-1:0] data_in;
    output  wire        [THREAD_NUM-1:0]            w_ready;
    output  wire        [THREAD_NUM-1:0]            r_ready;
    // output data
    output  wire        [DATA_WIDTH*THREAD_NUM-1:0] data_out;

            // write enable
            wire        [THREAD_NUM-1:0]            w_ena;

            // read enable
            wire        [THREAD_NUM-1:0]            r_ena;

            // enable reading from cache
            wire                                    cache_ready;

            // data read from cache
            wire        [DATA_WIDTH-1:0]            cache2mem;

    // decode read/write enable from ctrl signal
    generate
        genvar i;
        for (i = 0; i < THREAD_NUM; i++) begin
            arashi_ctrl_decoder decoder(.ctrl(ctrl[i*2+1:i*2]),
                                        .w_ena(w_ena[i]),
                                        .r_ena(r_ena[i]));
        end
    endgenerate

    generate
        if (THREAD_NUM_WIDTH > 4) $error("Bad parameter THREAD_NUM_WIDTH=%d, it cannot be larger than 4", THREAD_NUM);
        if (THREAD_NUM_WIDTH < 2) $error("Bad parameter THREAD_NUM_WIDTH=%d, it cannot be smaller than 2", THREAD_NUM);
    endgenerate

    // for each thread, determin the write address
    arashi_cache # (DATA_WIDTH,
                    THREAD_NUM_WIDTH)
             cache (.clk(clk),
                    .rstn(rstn),
                    .w_ena(w_ena),
                    .cache_ready(cache_ready),
                    .data_in(data_in),
                    .w_ready(w_ready),
                    .data_out(cache2mem));

    arashi_mem # (DATA_WIDTH,
                  THREAD_NUM_WIDTH,
                  MEM_WIDTH)
             mem (.clk(clk),
                  .rstn(rstn),
                  .r_ena(r_ena),
                  .cache_ready(cache_ready),
                  .cache2mem(cache2mem),
                  .data_out(data_out),
                  .r_ready(r_ready));
endmodule
