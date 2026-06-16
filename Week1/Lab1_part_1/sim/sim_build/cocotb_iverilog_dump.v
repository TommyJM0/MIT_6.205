module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/daddyboi/Desktop/FPGA/Week1/Lab1_part_1/sim/sim_build/counter.fst");
    $dumpvars(0, counter);
end
endmodule
