module arashi_arbiter_4 (wr,
                         offset_in,
                         offset_out,
                         addr);
    input   wire    [3:0]               wr;
    input   wire    [4:0]               offset_in;
    output  wire    [4:0]               offset_out;
    output  logic   [19:0]              addr;
            logic   [2:0]               count;

            logic   [4:0]               addr0;
            logic   [4:0]               addr1;
            logic   [4:0]               addr2;
            logic   [4:0]               addr3;

    always_comb
        case (wr)
        4'b0000: begin
            addr0 = 0;
            addr1 = 0;
            addr2 = 0;
            addr3 = 0;
            count = 0;
        end

        4'b0001: begin
            addr0 = offset_in;
            addr1 = 0;
            addr2 = 0;
            addr3 = 0;
            count = 1;
        end

        4'b0010: begin
            addr0 = 0;
            addr1 = offset_in;
            addr2 = 0;
            addr3 = 0;
            count = 1;
        end

        4'b0011: begin
            addr0 = offset_in;
            addr1 = offset_in + 1;
            addr2 = 0;
            addr3 = 0;
            count = 2;
        end

        4'b0100: begin
            addr0 = 0;
            addr1 = 0;
            addr2 = offset_in;
            addr3 = 0;
            count = 1;
        end

        4'b0101: begin
            addr0 = offset_in;
            addr1 = 0;
            addr2 = offset_in + 1;
            addr3 = 0;
            count = 2;
        end

        4'b0110: begin
            addr0 = 0;
            addr1 = offset_in;
            addr2 = offset_in + 1;
            addr3 = 0;
            count = 2;
        end

        4'b0111: begin
            addr0 = offset_in;
            addr1 = offset_in + 1;
            addr2 = offset_in + 2;
            addr3 = 0;
            count = 3;
        end

        4'b1000: begin
            addr0 = 0;
            addr1 = 0;
            addr2 = 0;
            addr3 = offset_in;
            count = 1;
        end

        4'b1001: begin
            addr0 = offset_in;
            addr1 = 0;
            addr2 = 0;
            addr3 = offset_in + 1;
            count = 2;
        end

        4'b1010: begin
            addr0 = 0;
            addr1 = offset_in;
            addr2 = 0;
            addr3 = offset_in + 1;
            count = 3;
        end

        4'b1011: begin
            addr0 = offset_in;
            addr1 = offset_in + 1;
            addr2 = 0;
            addr3 = offset_in + 2;
            count = 3;
        end

        4'b1100: begin
            addr0 = 0;
            addr1 = 0;
            addr2 = offset_in;
            addr3 = offset_in + 1;
            count = 2;
        end

        4'b1101: begin
            addr0 = offset_in;
            addr1 = 0;
            addr2 = offset_in + 1;
            addr3 = offset_in + 2;
            count = 3;
        end

        4'b1110: begin
            addr0 = 0;
            addr1 = offset_in;
            addr2 = offset_in + 1;
            addr3 = offset_in + 2;
            count = 3;
        end

        4'b1111: begin
            addr0 = offset_in;
            addr1 = offset_in + 1;
            addr2 = offset_in + 2;
            addr3 = offset_in + 3;
            count = 4;
        end
        endcase

    assign offset_out = offset_in + count;
    assign addr = { addr3, addr2, addr1, addr0 };
endmodule
