module arashi_cache # (DATA_WIDTH,
                       THREAD_NUM_WIDTH)
                      (clk,
                       rstn,
                       w_ena,
                       data_in,
                       w_ready,
                       data_out,
                       cache_ready);
    localparam THREAD_NUM = 1 << THREAD_NUM_WIDTH;
    input   wire                                clk;
    input   wire                                rstn;
    input   wire    [THREAD_NUM-1:0]            w_ena;
    input   wire    [DATA_WIDTH*THREAD_NUM-1:0] data_in;
    output  wire    [THREAD_NUM-1:0]            w_ready;
    output  wire    [DATA_WIDTH-1:0]            data_out;
    output  wire                                cache_ready;

            wire    [THREAD_NUM-1:0]            avail;
            wire    [THREAD_NUM_WIDTH-1:0]      read_thread_id;
            wire    [DATA_WIDTH-1:0]            data_all            [THREAD_NUM-1:0];
            wire    [THREAD_NUM-1:0]            r_ena;
            reg     [THREAD_NUM_WIDTH-1:0]      read_thread_id_reg;

    always_ff @ (posedge clk) begin
        if (!rstn) begin
            read_thread_id_reg <= 0;
        end else begin
            read_thread_id_reg <= read_thread_id;
        end
    end

    assign r_ena = cache_ready << read_thread_id;
    assign data_out = data_all[read_thread_id_reg];

    generate
    genvar i;
    for (i = 0; i < THREAD_NUM; i++) begin
        arashi_thread_cache # (DATA_WIDTH) thread_cache(.clk(clk),
                                                        .rstn(rstn),
                                                        .w_ena(w_ena[i]), 
                                                        .r_ena(r_ena[i]), 
                                                        .data_in(data_in[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]),
                                                        .w_ready(w_ready[i]),
                                                        .data_out(data_all[i]),
                                                        .avail(avail[i]));
    end
    endgenerate

    arashi_arbiter # (DATA_WIDTH,
                      THREAD_NUM_WIDTH) 
             arbiter (.clk(clk),
                      .rstn(rstn),
                      .avail(avail),
                      .thread_id(read_thread_id),
                      .ready(cache_ready));
endmodule
