module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/daddyboi/Desktop/FPGA/Week1/lab1_part_2/sim/sim_build/rgb_controller.fst");
    $dumpvars(0, rgb_controller);
end
endmodule
