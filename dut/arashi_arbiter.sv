module arashi_arbiter # (DATA_WIDTH,
                         THREAD_NUM_WIDTH)
                        (clk,
                         rstn,
                         avail,
                         thread_id,
                         ready);
    localparam THREAD_NUM = 1 << THREAD_NUM_WIDTH;

    input   wire                                    clk;
    input   wire                                    rstn;
    input   wire    [THREAD_NUM-1:0]                avail;
    output  logic   [THREAD_NUM_WIDTH-1:0]          thread_id;
    output  logic                                   ready;

            wire    [THREAD_NUM-1:0]                savail;
            logic   [THREAD_NUM_WIDTH-1:0]          next;
            wire                                    any_avail;

    always_ff @ (posedge clk) begin
        if (!rstn) begin
            thread_id <= 0;
            ready <= 0;
        end else begin
            if (any_avail) begin
                thread_id <= thread_id + next;
                ready <= 1;
            end else begin
                thread_id <= 0;
                ready <= 0;
            end
        end
    end

    assign savail = { avail, avail } >> (thread_id + 1);
    assign any_avail = |avail;

`ifdef SIM
    generate
        if (THREAD_NUM_WIDTH == 2) begin
            active_0 a0(next[0], savail[0], savail[1], savail[2], savail[3]);
            active_1 a1(next[1], savail[0], savail[1], savail[2], savail[3]);
        end
        if (THREAD_NUM_WIDTH == 3) begin
            wire    [1:0]          next_0;
            wire    [1:0]          next_1;
            wire                   any_avail_0;
            wire                   any_avail_1;
            active_0    a0_0 (next_0[0],   savail[0], savail[1], savail[2], savail[3]);
            active_1    a1_0 (next_0[1],   savail[0], savail[1], savail[2], savail[3]);
            active_any  any_0(any_avail_0, savail[0], savail[1], savail[2], savail[3]);

            active_0    a0_1 (next_0[0],   savail[4], savail[5], savail[6], savail[7]);
            active_1    a1_1 (next_0[1],   savail[4], savail[5], savail[6], savail[7]);
            active_any  any_1(any_avail_1, savail[4], savail[5], savail[6], savail[7]);

            assign next[2]   = any_avail_0 ? 0         : any_avail_1;
            assign next[1]   = any_avail_0 ? next_0[1] : next_1[1];
            assign next[0]   = any_avail_0 ? next_0[0] : next_1[0];
        end
        if (THREAD_NUM_WIDTH == 4) begin
            wire    [1:0]          next_0;
            wire    [1:0]          next_1;
            wire    [1:0]          next_2;
            wire    [1:0]          next_3;
            wire                   any_avail_0;
            wire                   any_avail_1;
            wire                   any_avail_2;
            wire                   any_avail_3;

            active_0    a0_0 (next_0[0],   savail[0],  savail[1],  savail[2],  savail[3]);
            active_1    a1_0 (next_0[1],   savail[0],  savail[1],  savail[2],  savail[3]);
            active_any  any_0(any_avail_0, savail[0],  savail[1],  savail[2],  savail[3]);

            active_0    a0_1 (next_1[0],   savail[4],  savail[5],  savail[6],  savail[7]);
            active_1    a1_1 (next_1[1],   savail[4],  savail[5],  savail[6],  savail[7]);
            active_any  any_1(any_avail_1, savail[4],  savail[5],  savail[6],  savail[7]);

            active_0    a0_2 (next_2[0],   savail[8],  savail[9],  savail[10], savail[11]);
            active_1    a1_2 (next_2[1],   savail[8],  savail[9],  savail[10], savail[11]);
            active_any  any_2(any_avail_2, savail[8],  savail[9],  savail[10], savail[11]);

            active_0    a0_3 (next_3[0],   savail[12], savail[13], savail[14], savail[15]);
            active_1    a1_3 (next_3[1],   savail[12], savail[13], savail[14], savail[15]);
            active_any  any_3(any_avail_3, savail[12], savail[13], savail[14], savail[15]);

            assign next[3]   = any_avail_0 ? 0 : 
                               any_avail_1 ? 0 :
                               any_avail_2 ? 1 : any_avail_3;
            assign next[2]   = any_avail_0 ? 0 :
                               any_avail_1 ? 1 :
                               any_avail_2 ? 0 : any_avail_3;
            assign next[1]   = any_avail_0 ? next_0[1] :
                               any_avail_1 ? next_1[1] :
                               any_avail_2 ? next_2[1] : next_3[1];
            assign next[0]   = any_avail_0 ? next_0[0] :
                               any_avail_1 ? next_1[0] :
                               any_avail_2 ? next_2[0] : next_3[0];
        end
    endgenerate
`else
    generate
    if (THREAD_NUM_WIDTH == 2) begin
        always_comb begin
            if (savail[0])      next = 2'b00;
            else if (savail[1]) next = 2'b01;
            else if (savail[2]) next = 2'b10;
            else if (savail[3]) next = 2'b11;
            else                next = 2'b00;
        end
    end
    if (THREAD_NUM_WIDTH == 3) begin
        always_comb begin
            if (savail[0])     next = 3'b000;
            else if(savail[1]) next = 3'b001;
            else if(savail[2]) next = 3'b010;
            else if(savail[3]) next = 3'b011;
            else if(savail[4]) next = 3'b100;
            else if(savail[5]) next = 3'b101;
            else if(savail[6]) next = 3'b110;
            else if(savail[7]) next = 3'b111;
            else               next = 3'b000;
        end
    end
    if (THREAD_NUM_WIDTH == 4) begin
        always_comb begin
            if (savail[0])      next = 4'b0000;
            else if(savail[1])  next = 4'b0001;
            else if(savail[2])  next = 4'b0010;
            else if(savail[3])  next = 4'b0011;
            else if(savail[4])  next = 4'b0100;
            else if(savail[5])  next = 4'b0101;
            else if(savail[6])  next = 4'b0110;
            else if(savail[7])  next = 4'b0111;
            else if(savail[8])  next = 4'b111;
            else if(savail[9])  next = 4'b1001;
            else if(savail[10]) next = 4'b1010;
            else if(savail[11]) next = 4'b1011;
            else if(savail[12]) next = 4'b1100;
            else if(savail[13]) next = 4'b1101;
            else if(savail[14]) next = 4'b1110;
            else if(savail[15]) next = 4'b1111;
            else                next = 4'b0000;
        end
    end
    endgenerate
`endif
endmodule

`ifdef SIM
primitive active_0(output o0,
                   input  i0,
                   input  i1,
                   input  i2,
                   input  i3);
    table
    //  i0 i1 i2 i3  o1
        1  ?  ?  ? : 0;
        0  1  ?  ? : 1;
        0  0  1  ? : 0;
        0  0  0  1 : 1;
        0  0  0  0 : 0;
    endtable
endprimitive

primitive active_1(output o1,
                   input  i0,
                   input  i1,
                   input  i2,
                   input  i3);
    table
    //  i0 i1 i2 i3  o1
        1  ?  ?  ? : 0;
        0  1  ?  ? : 0;
        0  0  1  ? : 1;
        0  0  0  1 : 1;
        0  0  0  0 : 0;
    endtable
endprimitive

primitive active_any(output o,
                     input  i0,
                     input  i1,
                     input  i2,
                     input  i3);
    table
    //  i0 i1 i2 i3  o1
        1  ?  ?  ? : 1;
        0  1  ?  ? : 1;
        0  0  1  ? : 1;
        0  0  0  1 : 1;
        0  0  0  0 : 0;
    endtable
endprimitive
`endif
