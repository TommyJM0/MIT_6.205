import cocotb
import os
import random
import sys
import logging
from pathlib import Path
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge, ReadOnly
from cocotb.utils import get_sim_time as gst
from cocotb.runner import get_runner
test_file = os.path.basename(__file__).replace(".py","")

@cocotb.test()
async def test_a(dut):
    """cocotb test for testing the evt counter!"""
    dut._log.info("Starting...")
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    dut.rst.value = 1
    await ClockCycles(dut.clk, 3)
    dut.rst.value = 0
    await ClockCycles(dut.clk, 3)
    dut.din.value = 0x35
    await ClockCycles(dut.clk, 10000)
    dut.trigger.value = 1
    await ClockCycles(dut.clk, 1)
    dut.trigger.value = 0
    await Timer(600000, units = 'ns')
    dut.trigger.value = 1
    await ClockCycles(dut.clk, 10000)
    dut.trigger.value = 0
    await Timer(600000, units = 'ns')
    dut.rst.value = 1
    await Timer(10000, units = 'ns')

def evt_counter_runner():
    """Simulate the evt_counter using the Python runner."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "UART_transmit.sv"] #grow/modify this as needed.
    build_test_args = ["-Wall"]#,"COCOTB_RESOLVE_X=ZEROS"]
    parameters = {"INPUT_CLOCK_FREQ" : 100_000_000, "BAUD_RATE" : 9600} #!!! nice figured it out.
    sys.path.append(str(proj_path / "sim"))
    hdl_toplevel = "UART_transmit"
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel=hdl_toplevel,
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale = ('1ns','1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel=hdl_toplevel,
        test_module=test_file,
        test_args=run_test_args,
        waves=True
    )
if __name__ == "__main__":
    evt_counter_runner()




