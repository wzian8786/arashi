module arashi_thread_cache # (DATA_WIDTH)
                             (clk,
                              rstn,
                              w_ena,
                              w_id,
                              r_ena,
                              data_in,
                              w_ready,
                              data_out,
                              avail);
    input   wire                        clk;
    input   wire                        rstn;
    input   wire                        w_ena;
    input   wire                        w_id;
    input   wire                        r_ena;
    input   wire    [DATA_WIDTH-1:0]    data_in;
    output  logic                       w_ready;
    output  logic   [DATA_WIDTH-1:0]    data_out;
    output  wire                        avail;

            logic   [DATA_WIDTH-1:0]    buff[3:0];
            logic   [1:0]               w_ptr;
            logic   [1:0]               r_ptr;
            logic                       last_id;
            wire    [1:0]               backlog;

    always_ff @ (posedge clk) begin
        if (!rstn) begin
            w_ready             <= 0;
            data_out            <= 0;
            buff[3]             <= 0;
            buff[2]             <= 0;
            buff[1]             <= 0;
            buff[0]             <= 0;
            w_ptr               <= 0;
            r_ptr               <= 0;
            last_id             <= 0;
        end
        else begin 
            if (w_ena) begin
                if (w_id != last_id && backlog != 2'b11) begin
                    buff[w_ptr] <= data_in;
                    w_ptr       <= w_ptr + 1;
                    w_ready     <= 1;
                    last_id     <= w_id;
                end
            end
            else begin
                w_ready         <= 0;
            end
            if (r_ena && backlog > 0) begin
                data_out    <= buff[r_ptr];
                r_ptr       <= r_ptr + 1;
            end
            else begin
                data_out    <= 0;
            end
        end
    end

    assign backlog = w_ptr - r_ptr;
    // It's not neccesary to make arbiter wait for an extra cycle
    // assign avail = |backlog;
    assign avail = (backlog == 0) ? w_ena :
                   (backlog == 1) ? ~r_ena : 1;
endmodule
