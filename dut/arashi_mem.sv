module arashi_mem # (DATA_WIDTH,
                     THREAD_NUM_WIDTH,
                     MEM_WIDTH)
                    (clk,
                     rstn,
                     r_ena,
                     cache_ready,
                     cache2mem,
                     data_out,
                     r_ready);
    localparam THREAD_NUM = 1 << THREAD_NUM_WIDTH;
    localparam NO_MORE    = (1 << MEM_WIDTH) - 1;

    input   wire                                clk;
    input   wire                                rstn;
    input   wire    [THREAD_NUM-1:0]            r_ena;
    input   wire                                cache_ready;
    input   wire    [DATA_WIDTH-1:0]            cache2mem;
    output  wire    [DATA_WIDTH*THREAD_NUM-1:0] data_out;
    output  logic   [THREAD_NUM-1:0]            r_ready;

            logic   [MEM_WIDTH-1:0]             wptr;
            logic   [MEM_WIDTH-1:0]             rptr;
            logic                               cache_ready_reg;

            wire    [THREAD_NUM_WIDTH-1:0]      read_thread_id;
            wire                                read_ready;
            logic   [MEM_WIDTH-1:0]             backlog;

`ifdef SIM
            logic   [DATA_WIDTH-1:0]    mem[(1<<MEM_WIDTH)-1:0];
`endif
    always_ff @ (posedge clk) begin
        if (!rstn) begin
            for (integer i = 0; i < 1 << MEM_WIDTH; i++) begin
`ifdef SIM
                mem[i] <= 0;
`endif
            end
            wptr <= 0;
            rptr <= 0;
            cache_ready_reg <= 0;
        end
        else begin
            cache_ready_reg <= cache_ready;

            if (cache_ready_reg && backlog != NO_MORE) begin
`ifdef SIM
                mem[wptr] <= cache2mem;
`endif
                wptr <= wptr + 1;
            end

            if (read_ready && backlog > 0) begin
`ifdef SIM
                data_out[(read_thread_id+1)*DATA_WIDTH-1:read_thread_id*DATA_WIDTH] = mem[rptr];
`endif
                rptr <= rptr + 1;
                r_ready <= 1 << read_thread_id;
            end
            else begin
                r_ready = 0;
            end
        end
    end

    assign backlog = wptr - rptr;

    arashi_arbiter # (DATA_WIDTH,
                      THREAD_NUM_WIDTH) 
             arbiter (.clk(clk),
                      .rstn(rstn),
                      .avail(r_ena),
                      .thread_id(read_thread_id),
                      .ready(read_ready));
endmodule
