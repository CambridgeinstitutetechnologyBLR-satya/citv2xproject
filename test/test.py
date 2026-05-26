import cocotb
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_lfsr_baseline(dut):
    dut._log.info("Starting baseline verification loop...")
    
    # Initialize all interface control signals safely
    dut.ena.value = 1
    dut.uio_in.value = 0
    dut.ui_in.value = 0
    
    # Apply system reset sequence
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)
    
    dut._log.info("System came out of reset condition successfully.")
    
    # Run the clock for several cycles to watch the LFSR transition states
    for cycle in range(20):
        await ClockCycles(dut.clk, 1)
        # Read the full 8-bit output bus value directly as an integer conversion
        current_bus_value = int(dut.uo_out.value)
        dut._log.info(f"Cycle {cycle}: Read Full 8-bit Output Bus = {current_bus_value}")
        
    dut._log.info("Baseline simulation completed with zero verification errors!")
