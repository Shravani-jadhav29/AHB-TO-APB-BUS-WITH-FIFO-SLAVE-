# AHB-TO-APB-BUS-WITH-FIFO-SLAVE-
# AHB to APB Bus Bridge with FIFO Slave

## Overview
This project implements an **AHB (Advanced High-performance Bus) to APB (Advanced Peripheral Bus) Bridge** featuring an integrated asynchronous/synchronous FIFO slave buffer. The bridge allows high-speed AHB master devices (such as CPUs or DMA controllers) to seamlessly transfer data to low-power, lower-speed APB peripherals without stalling the AHB system.

## Features
* **Protocol Conversion:** Efficiently bridges AMBA AHB (high performance, pipelined) to AMBA APB (low power, non-pipelined).
* **FIFO Buffering:** Implements a FIFO buffer in the slave interface to smooth out data rate differences and handle burst transactions.
* **Flow Control:** Generates appropriate wait states (`HREADY`) and response signals (`HRESP`) back to the AHB master when the FIFO buffer is full or empty.
* **Configurable Parameters:** Customizable data width, address width, and FIFO depth.

## Architecture & System Block Diagram


### Key Components
1. **AHB Slave Interface:** Captures AHB transfer signals (`HTRANS`, `HWRITE`, `HADDR`, `HWDATA`), decoding address ranges and controlling transfer readiness (`HREADYOUT`).
2. **FIFO Buffer:** Temporarily stores incoming write data and control signals to decouple high-speed AHB burst transfers from slow APB completions.
3. **APB Master Interface:** Reads from the FIFO and generates standard APB transfer sequences (`PSEL`, `ENABLE`, `PADDR`, `PWDATA`, `PWRITE`).

## Signal Descriptions

### AHB Interface Signals
* `HCLK` / `HRESETn`: Clock and active-low reset signals.
* `HADDR [31:0]`: Address bus.
* `HTRANS [1:0]`: Transfer type (IDLE, BUSY, NONSEQ, SEQ).
* `HWRITE`: Transfer direction (1 = Write, 0 = Read).
* `HWDATA [31:0]`: Write data bus.
* `HRDATA [31:0]`: Read data bus back to AHB master.
* `HREADYOUT`: Status signal indicating the bridge is ready for a new transfer.
* `HRESP`: Transfer status (OKAY / ERROR).

### APB Interface Signals
* `PCLK` / `PRESETn`: Clock and active-low reset signals.
* `PSEL`: Peripheral select line.
* `PENABLE`: APB strobe signal indicating the second cycle of an APB transfer.
* `PADDR [31:0]`: APB address bus.
* `PWRITE`: Control signal specifying write (1) or read (0).
* `PWDATA [31:0]`: APB write data bus.
* `PRDATA [31:0]`: APB read data bus from slave peripheral.

## Getting Started

### Prerequisites
* **Verilog/SystemVerilog Compiler:** ModelSim, Icarus Verilog, or EDA Playground.
* **Waveform Viewer:** GTKWave or ModelSim for analyzing `.vcd` traces.

### Simulation
To run the simulation using Icarus Verilog and GTKWave:

```bash
# Compile design and testbench files
iverilog -o ahb_apb_tb.out src/*.v tb/*.v

# Run simulation
vvp ahb_apb_tb.out

# View waveforms
gtkwave dump.vcd
