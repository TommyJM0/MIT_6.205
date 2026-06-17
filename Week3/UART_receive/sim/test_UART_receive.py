
import cocotb
import os
import random
import sys
from math import log
import logging
from pathlib import Path
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge, ReadOnly,with_timeout
from cocotb.utils import get_sim_time as gst
from cocotb.runner import get_runner
test_file = os.path.basename(__file__).replace(".py","")

import cocotb
from cocotb.triggers import ClockCycles, RisingEdge

async def uart_send_message(dut, message, clk_freq=100000000, baud_rate=9600):
    """
    Transmits a string or a list of bytes over the UART 'din' line.
    
    Protocol: Idle (1) -> Start Bit (0) -> 8 Data Bits (LSB first) -> Stop Bit (1)
    """
    # Calculate how many clock cycles a single bit lasts
    cycles_per_bit = int(clk_freq / baud_rate)
    
    # Convert string to bytes if necessary
    if isinstance(message, str):
        byte_data = message.encode('utf-8')
    else:
        byte_data = message

    dut._log.info(f"Starting UART transmission of {len(byte_data)} bytes...")
    
    # 1. Ensure the line starts in the IDLE state (High)
    dut.din.value = 1
    await ClockCycles(dut.clk, cycles_per_bit) # Hold idle for a bit

    for byte in byte_data:
        # --- START BIT ---
        dut.din.value = 0
        await ClockCycles(dut.clk, cycles_per_bit)
        
        # --- DATA BITS (LSB to MSB) ---
        for bit_idx in range(8):
            bit = (byte >> bit_idx) & 0x01
            dut.din.value = bit
            await ClockCycles(dut.clk, cycles_per_bit)
            
        # --- STOP BIT ---
        dut.din.value = 1
        await ClockCycles(dut.clk, cycles_per_bit)
        
    dut._log.info("UART transmission complete.")

@cocotb.test()
async def test_a(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut._log.info("Holding reset...")
    dut.rst.value = 1
    dut.din.value = 1
    await ClockCycles(dut.clk, 3) #wait three clock cycles
    dut.rst.value = 0 #un reset device
    await ClockCycles(dut.clk, 3) #wait a few clock cycles
    dut._log.info("Setting Trigger")
    cocotb.start_soon(uart_send_message(dut,[235]))
    await Timer(1200000, units = 'ns')

def uart_receive_runner():
    """Simulate the counter using the Python runner."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "UART_receive.sv"]
    build_test_args = ["-Wall"]
    parameters = {'INPUT_CLOCK_FREQ': 100000000, 'BAUD_RATE':9600} #!!!change these to do different versions
    sys.path.append(str(proj_path / "sim"))
    hdl_toplevel = "UART_receive"
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
    uart_receive_runner()
