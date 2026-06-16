module pwm(   input wire clk,
              input wire rst,
              input wire [7:0] dc_in,
              output logic sig_out);
 
    logic [31:0] count;
    counter mc (.clk(clk),
                .rst(rst),
                .period(255),
                .count(count));
    assign sig_out = count<dc_in; //very simple threshold check
endmodule