module arashi_cache # (THREAD_NUM,
                       DATA_WIDTH)
                      (clk,
                       rstn,
                       w_ena,
                       r_ena,
                       data_in,
                       data_out);
    input   wire                                clk;
    input   wire                                rstn;
    input   wire    [THREAD_NUM-1:0]            w_ena;
    input   wire    [THREAD_NUM-1:0]            r_ena;
    input   wire    [DATA_WIDTH*THREAD_NUM-1:0] data_in;
    output  wire    [DATA_WIDTH*THREAD_NUM-1:0] data_out;

    generate
    genvar i;
    for (i = 0; i < THREAD_NUM; i++) begin
        arashi_thread_cache # (DATA_WIDTH) thread_cache(.clk(clk),
                                                        .rstn(rstn),
                                                        .w_ena(w_ena[i]), 
                                                        .r_ena(r_ena[i]), 
                                                        .data_in(data_in[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]),
                                                        .data_out(data_out[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]));
    end
    endgenerate
endmodule
