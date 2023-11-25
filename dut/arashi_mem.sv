module arashi_mem # (DATA_WIDTH,
                     MEM_WIDTH,
                     THREAD_NUM_WIDTH)
                    (clk,
                     rstn,
                     avail,
                     r_ena);
    localparam THREAD_NUM = 1 << THREAD_NUM_WIDTH;

    input   wire                                    clk;
    input   wire                                    rstn;
    input   wire    [THREAD_NUM-1:0]                avail;
    output  logic   [THREAD_NUM-1:0]                r_ena;

            logic   [THREAD_NUM_WIDTH-1:0]          toread;
            wire    [THREAD_NUM-1:0]                savail;
            wire    [THREAD_NUM_WIDTH-1:0]          next;
            wire                                    any_avail;

    always_ff @ (posedge clk) begin
        if (!rstn) begin
            r_ena <= 0;
            toread <= 0;
        end else begin
            if (any_avail) begin
                r_ena <= 1 << toread;
                toread <= toread + next;
            end
        end
    end

    assign savail = { avail, avail } >> toread;
    assign any_avail = |avail;

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
endmodule

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
