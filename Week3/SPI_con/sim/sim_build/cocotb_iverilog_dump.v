module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/daddyboi/Desktop/MIT_6.205/Week3/SPI_con/sim/sim_build/spi_con.fst");
    $dumpvars(0, spi_con);
end
endmodule
