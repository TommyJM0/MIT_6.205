module cocotb_iverilog_dump();
initial begin
    string dumpfile_path;    if ($value$plusargs("dumpfile_path=%s", dumpfile_path)) begin
        $dumpfile(dumpfile_path);
    end else begin
        $dumpfile("/Users/daddyboi/Desktop/MIT_6.205/Week3/UART_receive/sim/sim_build/UART_receive.fst");
    end
    $dumpvars(0, UART_receive);
end
endmodule
