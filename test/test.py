import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting 8-bit LFSR Hardware Verification Test")

    # Generate a standard clock signal on the clk pin (10us period)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Apply synchronous Active-Low Reset
    dut._log.info("Applying Reset State...")
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 5)
    
    # Release Reset
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    dut._log.info("Reset released. LFSR tracking initiated.")

    # Cycle through and log outputs to ensure a non-zero, shifting pattern
    previous_value = -1
    for cycle in range(15):
        await RisingEdge(dut.clk)
        current_value = int(dut.uo_out.value)
        dut._log.info(f"Clock Cycle {cycle:02d} -> Random Byte Output: 0x{current_value:02x}")
        
        # Verify safety rules
        assert current_value != 0, f"Critical Failure: LFSR collapsed to 0x00 on cycle {cycle}!"
        assert current_value != previous_value, f"Critical Failure: Circuit stuck at value 0x{current_value:02x}!"
        
        previous_value = current_value

    dut._log.info("All verification assertions passed successfully!")
