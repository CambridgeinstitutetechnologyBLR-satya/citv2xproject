import cocotb
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):

    dut._log.info("Starting verification...")

    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)

    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    for cycle in range(10):
        await ClockCycles(dut.clk, 1)
        dut._log.info(
            f"Cycle {cycle}: uo_out = {dut.uo_out.value}"
        )

    dut._log.info("Test complete")
