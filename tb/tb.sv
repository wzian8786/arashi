`timescale 1ns/1ps;
class R;
    rand logic  [7:0]   ctrl;
    rand logic  [127:0] data_in;
endclass

module tb;
    reg clk;
    reg rstn;

    logic   [7:0]       ctrl;
    logic   [127:0]     data_in;
    wire    [127:0]     data_out;

    R               r;

    always #5 clk = ~clk;

    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(0, tb);
        clk = 1'b0;
        ctrl[0] = 0;
        ctrl[1] = 0;
        ctrl[2] = 0;
        ctrl[3] = 0;
        #1 rstn = 1'b0;
        #10 rstn = 1'b1;

        r = new();
        for (integer i = 0; i < 10000; i++) begin
            #10;
            r.randomize();
            ctrl = r.ctrl;
            data_in = r.data_in;
        end

        #10 $finish();
    end

    arashi_top dut(.clk(clk),
                   .rstn(rstn),
                   .ctrl(ctrl),
                   .data_in(data_in),
                   .data_out(data_out));
endmodule
