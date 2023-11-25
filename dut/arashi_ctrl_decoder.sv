module arashi_ctrl_decoder (ctrl,
                            w_ena,
                            r_ena);
    input   wire    [1:0]   ctrl;
    output  wire            w_ena;
    output  wire            r_ena;
    assign w_ena = ctrl[1];
    assign r_ena = ctrl[0] & ~ctrl[1];
endmodule
