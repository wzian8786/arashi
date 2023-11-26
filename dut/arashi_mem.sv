module arashi_mem # (DATA_WIDTH = 32,
                     MEM_WIDTH  = 10)
                    (clk,
                     rstn,
                     rcache,
                     cache2mem);
    input   wire                        clk;
    input   wire                        rstn;
    input   wire                        rcache;
    input   wire    [DATA_WIDTH-1:0]    cache2mem;
            logic   [MEM_WIDTH-1:0]     wptr;
            logic   [MEM_WIDTH-1:0]     rptr;
            logic                       rcache_reg;
`ifdef SIM
            logic   [DATA_WIDTH-1:0]    mem[(1<<MEM_WIDTH)-1:0];
    always_ff @ (posedge clk) begin
        if (!rstn) begin
            for (integer i = 0; i < 1 << MEM_WIDTH; i++) begin
                mem[i] <= 0;
            end
            wptr <= 0;
            rptr <= 0;
            rcache_reg <= 0;
        end
        else begin
            if (rcache_reg) begin
                mem[wptr] <= cache2mem;
            end
            rcache_reg <= rcache;
        end
    end
`endif
endmodule
