module d1(
    input wire         i_1,
    input wire         i_2,
    input wire         i_3,
    output logic       o_1,
    output logic       o_2);

    assign o_1 = (i_1 || i_2) ^ i_3
    assign o_2 = ((i_1||i_2)||i_3) && ( i_1 && i_2)

endmodule


module d2(
    input wire[7:0] a,
    input wire[7:0] b,
    input wire[7:0] c
    output wire[7:0] d);

    always_comb begin
        if(a > b) begin
            d = 8;
        end
        else if(a == b) begin
            d = 9;
        end
        else if(b - a < 12) begin
            d = 3;
        end
        else begin
            d = c;
        end
    end

endmodule
