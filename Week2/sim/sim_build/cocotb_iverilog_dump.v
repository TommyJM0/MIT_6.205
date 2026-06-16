module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/daddyboi/Desktop/FPGA/Week2/sim/sim_build/spi_con.fst");
    $dumpvars(0, spi_con);
end
endmodule
