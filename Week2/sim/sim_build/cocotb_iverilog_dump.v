module cocotb_iverilog_dump();
initial begin
    string dumpfile_path;    if ($value$plusargs("dumpfile_path=%s", dumpfile_path)) begin
        $dumpfile(dumpfile_path);
    end else begin
        $dumpfile("/Users/daddyboi/Desktop/MIT_6.205/Week2/sim/sim_build/evt_counter.fst");
    end
    $dumpvars(0, evt_counter);
end
endmodule
