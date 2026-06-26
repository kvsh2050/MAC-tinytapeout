import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, ClockCycles

@cocotb.test()
async def test(dut):
    # 1. Start a 10ns clock (5ns low, 5ns high)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # 2. Hold reset active-low at startup
    dut.rst_n.value = 0
    dut.ui_in.value  = 0   # count_start = 0
    dut.uio_in.value = 0   # count_in = 0
    dut.ena.value    = 1   # Enable Tiny Tapeout tile
    
    # Wait 5 clock cycles in reset state
    await ClockCycles(dut.clk, 5)
    
    # 3. Release reset cleanly *just after* a falling edge 
    # to avoid any setup/hold delta-cycle races with the rising edge
    await RisingEdge(dut.clk)
    await Timer(1, units="ns") 
    dut.rst_n.value = 1
    
    # 4. Step through clock edges and observe the increments
    await RisingEdge(dut.clk) # Edge 1: Counter goes 0 -> 1
    await Timer(1, units="ns") # Give the simulator 1ns to settle outputs
    assert dut.uo_out.value.integer == 1, f"Expected 1, got {dut.uo_out.value.integer}"
    
    await RisingEdge(dut.clk) # Edge 2: Counter goes 1 -> 2
    await Timer(1, units="ns")
    assert dut.uo_out.value.integer == 2, f"Expected 2, got {dut.uo_out.value.integer}"

    # 5. Test Priority Latch Mode
    dut.uio_in.value = 0xAA       # Value to load (170 decimal)
    dut.ui_in.value  = 1          # Toggle count_start = 1
    
    await RisingEdge(dut.clk)     # Edge 3: Registers latch the load value
    await Timer(1, units="ns")
    assert dut.uo_out.value.integer == 0xAA, f"Expected 0xAA, got {dut.uo_out.value.integer}"
    
    # 6. Return to regular counting mode
    dut.ui_in.value = 0
    await RisingEdge(dut.clk)     # Edge 4: Counter resumes counting (170 -> 171)
    await Timer(1, units="ns")
    assert dut.uo_out.value.integer == 171, f"Expected 171, got {dut.uo_out.value.integer}"