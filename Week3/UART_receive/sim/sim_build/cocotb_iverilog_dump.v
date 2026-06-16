module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/daddyboi/Desktop/MIT_6.205/Week3/UART_receive/sim/sim_build/UART_receive.fst");
    $dumpvars(0, UART_receive);
end
endmodule
