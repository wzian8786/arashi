module arashi_ctrl_decoder (ctrl,
                            w_ena,
                            r_ena,
                            w_id,
                            r_id);
    input   wire    [3:0]   ctrl;
    output  wire            w_ena;
    output  wire            r_ena;
    output  wire            w_id;
    output  wire            r_id;
    assign w_ena = ctrl[1];
    assign r_ena = ctrl[0];
    assign w_id  = ctrl[1] & ctrl[3];
    assign r_id  = ctrl[0] & ctrl[2];
endmodule
