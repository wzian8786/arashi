module arashi_cache # (DATA_WIDTH,
                       THREAD_NUM_WIDTH)
                      (clk,
                       rstn,
                       w_ena,
                       toread,
                       rcache,
                       data_in,
                       data_out,
                       avail);
    localparam THREAD_NUM = 1 << THREAD_NUM_WIDTH;
    input   wire                                clk;
    input   wire                                rstn;
    input   wire    [THREAD_NUM-1:0]            w_ena;
    input   wire    [THREAD_NUM_WIDTH-1:0]      toread;
    input   wire                                rcache;
    input   wire    [DATA_WIDTH*THREAD_NUM-1:0] data_in;
    output  wire    [DATA_WIDTH-1:0]            data_out;
    output  wire    [THREAD_NUM-1:0]            avail;

            wire    [DATA_WIDTH-1:0]            data_all    [THREAD_NUM-1:0];
            wire    [THREAD_NUM-1:0]            r_ena;
            reg     [THREAD_NUM_WIDTH-1:0]      toread_reg;

    always_ff @ (posedge clk) begin
        if (!rstn) begin
            toread_reg <= 0;
        end else begin
            toread_reg <= toread;
        end
    end

    assign r_ena = rcache << toread;
    assign data_out = data_all[toread_reg];

    generate
    genvar i;
    for (i = 0; i < THREAD_NUM; i++) begin
        arashi_thread_cache # (DATA_WIDTH) thread_cache(.clk(clk),
                                                        .rstn(rstn),
                                                        .w_ena(w_ena[i]), 
                                                        .r_ena(r_ena[i]), 
                                                        .data_in(data_in[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]),
                                                        .data_out(data_all[i]),
                                                        .avail(avail[i]));
    end
    endgenerate
endmodule
