<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project is a synchronously loadable (preset) 8-bit digital counter designed to test basic sequential logic, register latching, and control path multiplexing within a single Tiny Tapeout tile. 

The system operates based on two distinct modes governed by a 1-bit control flag:

1. **Normal Counting Mode:** When the control signal (`count_start`) is held LOW, the internal 8-bit register (`counter_reg`) increments by `1` on every rising edge of the system clock (`clk`).
2. **Priority Load Mode:** When `count_start` is driven HIGH, the counting sequence is interrupted. On the next rising clock edge, the internal register bypasses the adder logic and directly latches the 8-bit parallel value provided on the input bus (`count_in`).

The counter features an active-low asynchronous reset (`rst_n`) that instantly clears the internal tracking register to `8'h00` regardless of the clock state. The current state of the counter is continuously exposed in parallel on the dedicated output pins.

## How to test

To verify the functionality of the loadable counter via simulation or an external hardware testbench, follow these operational steps:

1. **System Initialization:** Drive the asynchronous reset line (`rst_n`) LOW to initialize the internal state, confirming that the output bus (`uo_out`) drops to `8'h00`. Bring `rst_n` back HIGH to enable normal operation.
2. **Verify Sequential Counting:** Ensure the control line `ui_in[0]` (`count_start`) is tied LOW. Apply a continuous clock signal to the `clk` pin. Observe that the output pins (`uo_out[7:0]`) increment sequentially from `0` to `255` before rolling over back to `0`.
3. **Verify Load Operations:** * Apply a specific 8-bit target data pattern (e.g., `8'hA5` or `8'b10100101`) to the bidirectional input bus `uio_in[7:0]` (`count_in`).
   * Assert the load enable switch by driving `ui_in[0]` (`count_start`) HIGH.
   * Cycle the clock once (`posedge clk`). The output bus (`uo_out`) will immediately jump to match the input value (`8'hA5`).
   * Deassert `ui_in[0]` back to LOW. On subsequent clock edges, verify that the counter resumes incrementing naturally starting from the new preset baseline value (e.g., `8'hA6`, `8'hA7`, etc.).

## External hardware

This project operates safely within standard digital voltage domains and does not require specialized external hardware modules. For manual evaluation, the following basic peripherals are recommended:
* **8x LED Array / Logic Analyzer:** Connected to the dedicated output lines (`uo_out[7:0]`) to visually track or record the binary state transitions of the counter.
* **8-Position DIP Switch Array:** Connected to the bidirectional pins (`uio_in[7:0]`) to statically set the 8-bit binary pattern intended for parallel loading.
* **Single Toggle Switch / Pushbutton:** Tied to the first dedicated input pin (`ui_in[0]`) to manually alternate between the normal counting and priority loading states.