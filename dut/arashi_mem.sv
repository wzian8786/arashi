module arashi_mem # (DATA_WIDTH,
                     THREAD_NUM_WIDTH,
                     MEM_WIDTH)
                    (clk,
                     rstn,
                     r_ena,
                     cache_ready,
                     mem_ready,
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
    output  wire                                mem_ready;
    output  logic   [THREAD_NUM-1:0]            r_ready;

            logic   [MEM_WIDTH-1:0]             wptr;
            logic   [MEM_WIDTH-1:0]             rptr;
            logic                               cache_ready_reg;

            wire    [THREAD_NUM_WIDTH-1:0]      read_thread_id;
            wire                                read_ready;
            logic   [MEM_WIDTH-1:0]             backlog;

`ifdef SIM
            logic   [DATA_WIDTH-1:0]            mem             [(1<<MEM_WIDTH)-1:0];
`endif

            logic   [DATA_WIDTH-1:0]            data_out_reg    [THREAD_NUM-1:0];

    generate
    if (THREAD_NUM_WIDTH == 2) begin
        assign data_out = {
            data_out_reg[3],
            data_out_reg[2],
            data_out_reg[1],
            data_out_reg[0]
        };
    end
    if (THREAD_NUM_WIDTH == 3) begin
        assign data_out = {
            data_out_reg[7],
            data_out_reg[6],
            data_out_reg[5],
            data_out_reg[4],
            data_out_reg[3],
            data_out_reg[2],
            data_out_reg[1],
            data_out_reg[0]
        };
    end
    if (THREAD_NUM_WIDTH == 4) begin
        assign data_out = {
            data_out_reg[15],
            data_out_reg[14],
            data_out_reg[13],
            data_out_reg[12],
            data_out_reg[11],
            data_out_reg[10],
            data_out_reg[9],
            data_out_reg[8],
            data_out_reg[7],
            data_out_reg[6],
            data_out_reg[5],
            data_out_reg[4],
            data_out_reg[3],
            data_out_reg[2],
            data_out_reg[1],
            data_out_reg[0]
        };
    end
    endgenerate

    always_ff @ (posedge clk) begin
        if (!rstn) begin
            for (integer i = 0; i < 1 << MEM_WIDTH; i++) begin
`ifdef SIM
                mem[i] <= 0;
`endif
            end
            for (integer i = 0; i < THREAD_NUM; i++) begin
                data_out_reg[i] <= 0;
            end
            wptr <= 0;
            rptr <= 0;
            cache_ready_reg <= 0;
            r_ready <= 0;
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
                for (integer i = 0; i < THREAD_NUM; ++i) begin
                    if (i == read_thread_id)
                        data_out_reg[i] <= mem[rptr];
                    else
                        data_out_reg[i] <= 0;
                end
`endif
                rptr <= rptr + 1;
                r_ready <= 1 << read_thread_id;
            end
            else begin
                for (integer i = 0; i < THREAD_NUM; ++i) begin
                    data_out_reg[i] <= 0;
                end
                r_ready = 0;
            end
        end
    end

    assign backlog = wptr - rptr;
    assign mem_ready = backlog != NO_MORE;

    arashi_arbiter # (DATA_WIDTH,
                      THREAD_NUM_WIDTH) 
             arbiter (.clk(clk),
                      .rstn(rstn),
                      .avail(r_ena),
                      .thread_id(read_thread_id),
                      .ready(read_ready));
endmodule
