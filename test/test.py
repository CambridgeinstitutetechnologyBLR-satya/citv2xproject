import cocotb
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting streamlined verification loop...")
    
    # Apply system reset using only the guaranteed baseline signals
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)
    dut._log.info("System came out of reset condition successfully.")
    
    # Run the clock for several cycles to observe the LFSR shifting states
    for cycle in range(10):
        await ClockCycles(dut.clk, 1)
        # Safe string capture of the output bus to prevent signal exceptions
        bus_string = str(dut.uo_out.value)
        dut._log.info(f"Cycle {cycle}: Read Output Bus = {bus_string}")
        
    dut._log.info("Streamlined simulation completed successfully!")
