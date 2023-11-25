module arashi_thread_cache # (DATA_WIDTH)
                             (clk,
                              rstn,
                              w_ena,
                              r_ena,
                              data_in,
                              data_out);
    input   wire                        clk;
    input   wire                        rstn;
    input   wire                        w_ena;
    input   wire                        r_ena;
    input   wire    [DATA_WIDTH-1:0]    data_in;
    output  logic   [DATA_WIDTH-1:0]    data_out;

            logic   [DATA_WIDTH-1:0]    buff[3:0];
            logic   [1:0]               w_ptr;
            logic   [1:0]               r_ptr;
            wire    [1:0]               backlog;

    always_ff @ (posedge clk) begin
        if (!rstn) begin
            buff[3]         <= 0;
            buff[2]         <= 0;
            buff[1]         <= 0;
            buff[0]         <= 0;
            w_ptr           <= 0;
            r_ptr           <= 0;
        end else begin 
            if (w_ena && backlog != 2'b11) begin
                buff[w_ptr] <= data_in;
                w_ptr       <= w_ptr + 1;
            end
            if (r_ena && backlog > 0) begin
                data_out    <= buff[r_ptr];
                r_ptr       <= r_ptr + 1;
            end
        end
    end

    assign backlog = w_ptr - r_ptr;
endmodule
