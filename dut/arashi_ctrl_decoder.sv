module arashi_ctrl_decoder (ctrl,
                            wr,
                            rd);
    input   wire    [1:0]   ctrl;
    output  wire            wr;
    output  wire            rd;
    assign wr = ctrl[1];
    assign rd = ctrl[0] & ~ctrl[1];
endmodule
