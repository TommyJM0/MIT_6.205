module rgb_controller(
    input wire clk,
    input wire rst,
    input wire [7:0] r_in,
    input wire [7:0] g_in,
    input wire [7:0] b_in,
    output logic r_out,
    output logic g_out,
    output logic b_out);
    

    pwm red(
        .clk(clk),
        .rst(rst),
        .dc_in(r_in),
        .sig_out(r_out)
    );

    pwm green(
        .clk(clk),
        .rst(rst),
        .dc_in(g_in),
        .sig_out(g_out)
    );

    pwm blue(
        .clk(clk),
        .rst(rst),
        .dc_in(b_in),
        .sig_out(b_out)
    );

endmodule