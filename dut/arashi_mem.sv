module arashi_mem # (DATA_WIDTH,
                     MEM_WIDTH,
                     THREAD_NUM)
                    (clk,
                     rstn,
                     wr,
                     waddr,
                     wdata);
    input   wire                                    clk;
    input   wire                                    rstn;
    input   wire    [THREAD_NUM-1:0]                wr;
    input   wire    [MEM_WIDTH*THREAD_NUM-1:0]      waddr;
    input   wire    [DATA_WIDTH*THREAD_NUM-1:0]     wdata;

            logic   [DATA_WIDTH-1:0]                mem [(1<<MEM_WIDTH)-1:0];

    integer i;

    always_ff @ (posedge clk) begin
        if (!rstn) begin
            for (i = 0; i < 1<<MEM_WIDTH; ++i) begin
                mem[i] <= 0;
            end
        end
        else begin
            mem[waddr[MEM_WIDTH-1:0]] <= wdata[DATA_WIDTH-1:0];
        end
    end
endmodule
