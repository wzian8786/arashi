module arashi_top # (DATA_WIDTH = 32,
                     MEM_WIDTH  = 10,
                     THREAD_NUM_WIDTH = 2)
                    (clk,
                     rstn,
                     ctrl,
                     data_in,
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
    // output data
    output  wire        [DATA_WIDTH*THREAD_NUM-1:0] data_out;

            // write enable
            wire        [THREAD_NUM-1:0]            w_ena;

            // read enable
            wire        [THREAD_NUM-1:0]            r_ena;

            // available for read
            wire        [THREAD_NUM-1:0]            avail;

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
    arashi_cache # (THREAD_NUM,
                    DATA_WIDTH)
             cache (.clk(clk),
                    .rstn(rstn),
                    .w_ena(w_ena),
                    .r_ena(r_ena),
                    .data_in(data_in),
                    .data_out(data_out),
                    .avail(avail));

    arashi_mem # (DATA_WIDTH,
                  MEM_WIDTH,
                  THREAD_NUM_WIDTH) 
             mem (.clk(clk),
                  .rstn(rstn),
                  .avail(avail));
endmodule
