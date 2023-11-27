module arashi_mem # (DATA_WIDTH,
                     THREAD_NUM_WIDTH,
                     MEM_WIDTH)
                    (clk,
                     rstn,
                     r_ena,
                     cache_ready,
                     cache2mem,
                     data_out);
    localparam THREAD_NUM = 1 << THREAD_NUM_WIDTH;
    input   wire                                clk;
    input   wire                                rstn;
    input   wire    [THREAD_NUM-1:0]            r_ena;
    input   wire                                cache_ready;
    input   wire    [DATA_WIDTH-1:0]            cache2mem;
    output  wire    [DATA_WIDTH*THREAD_NUM-1:0] data_out;

            logic   [MEM_WIDTH-1:0]             wptr;
            logic   [MEM_WIDTH-1:0]             rptr;
            logic                               cache_ready_reg;

            wire    [THREAD_NUM_WIDTH-1:0]      read_thread_id;
            wire                                read_ready;

`ifdef SIM
            logic   [DATA_WIDTH-1:0]    mem[(1<<MEM_WIDTH)-1:0];
    always_ff @ (posedge clk) begin
        if (!rstn) begin
            for (integer i = 0; i < 1 << MEM_WIDTH; i++) begin
                mem[i] <= 0;
            end
            wptr <= 0;
            rptr <= 0;
            cache_ready_reg <= 0;
        end
        else begin
            cache_ready_reg <= cache_ready;

            if (cache_ready_reg) begin
                mem[wptr] <= cache2mem;
                wptr  <= wptr + 1;
            end

            if (ready_read) begin
                data_out[(read_thread_id+1)*DATA_WIDTH-1:read_thread_id*DATA_WIDTH] = mem[rptr];
                rptr <= rptr + 1;
            end
        end
    end
`endif

    arashi_arbiter # (DATA_WIDTH,
                      THREAD_NUM_WIDTH) 
             arbiter (.clk(clk),
                      .rstn(rstn),
                      .avail(r_ena),
                      .thread_id(read_thread_id),
                      .ready(read_ready));
endmodule
