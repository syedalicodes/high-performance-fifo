# High-Performance FIFO with Verification

A parameterized synchronous First-In, First-Out (FIFO) buffer designed in SystemVerilog and verified using Xilinx Vivado 2018.2. This project demonstrates RTL design, self-checking simulation, assertion-based checks, FPGA synthesis, implementation, and static timing analysis.

## Overview

FIFO buffers are fundamental building blocks in digital systems. They temporarily store data and preserve ordering between a producer and a consumer. They are commonly used in FPGA designs, processor subsystems, digital communication interfaces, and SoC architectures.

This project implements a synchronous FIFO with configurable data width and depth, status flags, overflow and underflow protection, and a self-checking verification environment.

## Features

- Parameterized data width and FIFO depth
- Single-clock synchronous FIFO architecture
- Active-high synchronous reset
- Full and empty status flags
- Overflow and underflow protection
- Read and write pointer wraparound
- Occupancy counter
- Self-checking SystemVerilog testbench
- Procedural assertion checker compatible with the project’s Vivado 2018.2 simulation flow
- XDC clock and timing constraints
- FPGA synthesis, implementation, and timing analysis

## Design Specifications

| Parameter | Configuration |
|---|---|
| Design type | Synchronous FIFO |
| HDL | SystemVerilog |
| Default data width | 8 bits |
| Default depth | 16 entries |
| Storage capacity | 128 bits |
| Clock | Single clock |
| Reset | Active-high, synchronous |
| Status flags | Full, empty |
| FPGA target | Xilinx Artix-7, `xc7a35tcpg236-1` |
| Development tool | Xilinx Vivado 2018.2 |
| Hardware testing | Not performed; simulation and FPGA implementation only |

## Architecture

The design consists of a storage array, write pointer, read pointer, occupancy counter, and status-generation logic.

### Write operation

When `wr_en` is asserted and the FIFO is not full, the input data is stored at the write pointer. The pointer advances to the next location and wraps around at the end of the configured depth.

### Read operation

When `rd_en` is asserted and the FIFO is not empty, the oldest stored value is presented at `dout`. The read pointer advances and wraps around when required.

### Status flags

- `empty` is asserted when the occupancy count is zero.
- `full` is asserted when the occupancy count reaches the configured depth.
- Writes attempted while full are rejected.
- Reads attempted while empty are rejected.

When valid read and write operations occur together, both are performed and the occupancy count remains unchanged.

**Boundary behavior:** The current implementation rejects a write when the FIFO is already full, even if a read is requested in the same cycle. Similarly, a read is rejected when the FIFO is already empty, even if a write is requested simultaneously.

## Project File Structure

```text
high-performance-fifo/
├── sync_fifo.sv
├── tb_sync_fifo.sv
├── fifo_assertions.sv
├── fifo.xdc
├── README.md
├── utilization.png
├── timing_summary.png
├── design_runs.png
└── fifo_simulation.png
```

The PNG files are verification and implementation evidence captured from Vivado. They may alternatively be organized into `reports/` and `waveforms/` folders.

### File descriptions

| File | Description |
|---|---|
| `sync_fifo.sv` | Main synthesizable FIFO RTL |
| `tb_sync_fifo.sv` | Self-checking testbench |
| `fifo_assertions.sv` | Procedural checks for occupancy and status flags |
| `fifo.xdc` | Clock and timing constraints |
| `utilization.png` | Synthesis resource utilization |
| `timing_summary.png` | Static timing analysis results |
| `design_runs.png` | Synthesis and implementation status |
| `fifo_simulation.png` | Simulation waveform evidence |

## Verification Methodology

The testbench generates a clock and reset, applies FIFO transactions, checks returned data against expected values, and reports failures when actual behavior differs from expected behavior.

### Test cases

| Test case | Expected behavior | Result |
|---|---|---|
| Reset | FIFO becomes empty | PASS |
| Basic writes and reads | Data ordering is preserved | PASS |
| FIFO fill | Full flag asserts | PASS |
| Overflow attempt | Extra write is rejected | PASS |
| FIFO drain | Stored values are returned in order | PASS |
| Underflow attempt | Empty FIFO rejects read | PASS |
| Simultaneous read/write | Existing data is read and new data is written | PASS |
| Final state | FIFO returns to empty | PASS |

The testbench completed at 920 ns and printed `ALL TESTS PASSED`.

### Assertion checks

The assertion checker verifies:

- Occupancy does not exceed the configured depth.
- The full flag agrees with the occupancy count.
- The empty flag agrees with the occupancy count.

The project uses procedural simulation checks because the original SystemVerilog property declarations were not supported by the installed Vivado 2018.2 XSim version.

These checks complement the directed testbench but do not constitute exhaustive formal verification or complete coverage of all possible transactions.

## Synthesis and Implementation Results

The design was synthesized and implemented for the selected Artix-7 target in Vivado 2018.2.

### Resource utilization

| Resource | Reported usage |
|---|---:|
| Slice LUTs | 22 |
| Slice registers | 21 |
| Block RAMs | 0 |
| Bonded IOBs | 22 |
| BUFGCTRL | 1 |

The FIFO storage was not mapped to block RAM in the reported implementation. The utilization figures are specific to this design configuration, target device, and synthesis settings.

### Timing summary

| Timing metric | Reported result |
|---|---:|
| Worst Negative Slack (WNS) | +6.680 ns |
| Total Negative Slack (TNS) | 0.000 ns |
| Worst Hold Slack (WHS) | +0.095 ns |
| Total Hold Slack (THS) | 0.000 ns |
| Worst Pulse Width Slack | +3.750 ns |
| Setup failing endpoints | 0 |
| Hold failing endpoints | 0 |

The timing report indicates that all user-specified timing constraints were met.

The XDC includes a 10 ns clock target. Any assumed input/output delays should be treated as analysis assumptions rather than measured interface requirements. Timing results do not establish performance on physical hardware.

### Implementation status

- Synthesis: Completed successfully
- Implementation and routing: Completed successfully
- Failed routes: 0
- Behavioral simulation: Passed

## Tools and Technologies

- SystemVerilog
- RTL design
- Self-checking testbench development
- Procedural assertion-based verification
- Xilinx Vivado 2018.2
- XSim behavioral simulation
- XDC timing constraints
- FPGA synthesis and implementation
- Static timing analysis

## Future Improvements

- Compare FIFO depths of 8, 16, 32, and 64 entries using identical synthesis settings.
- Add constrained-random transactions and a reference-model scoreboard.
- Expand simultaneous read/write testing at full and empty boundaries.
- Explore block RAM inference for larger FIFO capacities.
- Add functional coverage and stronger assertion checks.
- Compare resource utilization and timing across multiple FIFO configurations.

These are planned extensions and are not claimed as completed results.

## Key Learning Outcomes

This project demonstrates practical experience with parameterized RTL development, pointer management, FIFO control logic, self-checking simulation, assertion-based checks, FPGA synthesis, implementation, and timing-report interpretation.

## Author

**Syed Ali U Khan**

Electronics and Communication Engineering — Microelectronic System Design

Interested in RTL Design, FPGA Design, VLSI Design Verification, and Digital Hardware Design.

---

*Developed and verified using Xilinx Vivado 2018.2. Simulation and implementation were performed without a physical FPGA board.*
