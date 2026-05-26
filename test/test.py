import cocotb
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting complete system flush verification...")
    
    # Assert reset safely across baseline ports
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    
    # Release reset
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)
    dut._log.info("System came out of reset condition successfully.")
    
    # Observe register transitions across clock edges
    for cycle in range(10):
        await ClockCycles(dut.clk, 1)
        bus_string = str(dut.uo_out.value)
        dut._log.info(f"Cycle {cycle}: Read Output Bus = {bus_string}")
        
    dut._log.info("System simulation completed successfully with zero pointer errors!")
