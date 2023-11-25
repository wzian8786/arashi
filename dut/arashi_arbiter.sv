module arashi_arbiter # (THREAD_NUM,
                         MEM_WIDTH)
                        (clk,
                         rstn,
                         wr,
                         maddr);
    input   wire                                    clk;
    input   wire                                    rstn;
    input   wire        [THREAD_NUM-1:0]            wr;
    output  logic       [MEM_WIDTH*THREAD_NUM-1:0]  maddr;

            logic       [MEM_WIDTH:0]               iptr;
            logic       [5*THREAD_NUM-1:0]          offset;
            logic       [5*THREAD_NUM-1:0]          addr;

    always_ff @ (posedge clk) begin
        if (!rstn) begin
            iptr <= 6'b000000;
        end else begin
            iptr <= iptr + offset[THREAD_NUM/4-1];
        end
    end

    `define LSB(i, m) i * m
    `define MSB(i, m) i * m + m - 1

    generate
    genvar i;
    for (i = 0; i < THREAD_NUM; i++)
        assign maddr[i*4+3:i*4] = iptr + addr[i*4+3:i*4];

    for (i = 0; i * 4 < THREAD_NUM; i++) begin
        if (i == 0)
            arashi_arbiter_4 count (.wr(wr[`MSB(i, 4):`LSB(i, 4)]),
                                    .offset_in(5'b00000),
                                    .offset_out(offset[`MSB(i, 5):`LSB(i, 5)]),
                                    .addr(addr[`MSB(i, 20):`LSB(i, 20)]));
        else
            arashi_arbiter_4 count (.wr(wr[`MSB(i, 4):`LSB(i, 4)]),
                                    .offset_in(offset[`MSB(i-1, 5):`LSB(i-1, 5)]),
                                    .offset_out(offset[`MSB(i, 5):`LSB(i, 5)]), 
                                    .addr(addr[`MSB(i, 20):`LSB(i, 20)]));
    end
    endgenerate
endmodule
