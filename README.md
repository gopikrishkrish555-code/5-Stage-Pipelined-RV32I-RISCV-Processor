# 5-Stage Pipelined RV32I RISC-V Processor on FPGA

A custom 32-bit **RV32I RISC-V** processor core implemented from scratch in **Verilog HDL**, featuring a classic 5-stage in-order pipeline, full data forwarding, hazard detection, and a memory-mapped UART serial peripheral. Synthesized, placed, routed, and verified on a **Sipeed Tang Nano 20K (Gowin GW2AR-18)** FPGA.

---

## Key Features

- **ISA Support:** Base 32-bit Integer Instruction Set (**RV32I**) — arithmetic/logical R-type & I-type instructions, loads/stores (`lw`, `sw`), conditional branches (`beq`, `bne`, `blt`, `bge`), and unconditional jumps (`jal`, `jalr`).
- **5-Stage Pipelined Architecture:**
  1. **IF (Instruction Fetch):** Program Counter (`pc.v`) with stall support and word-aligned instruction memory (`imem.v`).
  2. **ID (Instruction Decode):** 32x32-bit Register File (`reg_file.v`, `x0` hardwired to `0`), Main Control Unit (`control_unit.v`), and Immediate Generator (`imm_gen.v`).
  3. **EX (Execute):** 32-bit ALU (`alu.v`), branch condition & target evaluation, and EX-stage forwarding multiplexers.
  4. **MEM (Memory Access):** Data Memory (`dmem.v`) and Memory-Mapped I/O (MMIO) peripheral bus interface.
  5. **WB (Writeback):** Result selection between ALU output and memory read data.
- **Hazard Handling & Forwarding:**
  - **Forwarding Unit (`forwarding_unit.v`):** Resolves Read-After-Write (RAW) data hazards via **EX-to-EX** and **MEM-to-EX** forwarding paths.
  - **Hazard Detection Unit (`hazard_detection_unit.v`):** Detects load-use dependencies to insert pipeline stalls (bubbles) and flushes speculative instructions on taken branches/jumps.
- **SoC Peripherals & Hardware Debug:**
  - **MMIO UART Transmitter (`uart_tx.v`):** Configured at **115,200 baud** (234 clock cycles/bit at 27 MHz) mapped to address `0x0000_0100`.
  - **Onboard Visual Diagnostics:** Power-on reset sequencing, 27 MHz clock heartbeat indicator (`LED5`), and real-time hardware register readout (`x3[3:0]` mapped to `LED[3:0]`).

---

## Repository Structure

```text
├── riscv_rv32i/          # Gowin EDA FPGA project & synthesis wrapper
│   ├── src/              # Top-level SoC wrapper (tang_nano_top.v), UART TX, & core RTL
│   └── riscv_rv32i.gprj  # Gowin project file
├── rtl/                  # Standalone modular RV32I Verilog RTL source files
├── tb/                   # Self-checking Verilog testbenches (ALU, RegFile, Control, Core)
├── sw/                   # Machine code & hex test programs
├── sim/                  # Simulation scripts & waveform outputs
└── tang_nano_20k.cst     # Physical pin constraints for Tang Nano 20K
```

---

## Memory Map & Pinout (Tang Nano 20K)

| Address / Signal | Pin | Description |
| :--- | :---: | :--- |
| `0x0000_0100` (Write) | Pin 69 | Memory-Mapped UART TX (`115200 baud`, 8N1) via BL702 USB bridge |
| `clk_27m` | Pin 4 | Onboard 27 MHz crystal oscillator |
| `btn1` | Pin 88 | Onboard user tactile switch (`S1`) |
| `led[3:0]` | Pins 15–18 | Active-low LEDs displaying lower 4 bits of register `x3` |
| `led[4]` | Pin 19 | Active reset status indicator |
| `led[5]` | Pin 20 | ~1.6 Hz clock heartbeat LED |

---

## Hardware Verification Milestones

1. **RTL Simulation:** Verified individual modules (`alu`, `imm_gen`, `control_unit`, `reg_file`, `pc`) and full pipeline execution using **Icarus Verilog** and **GTKWave**.
2. **Iterative Loop Execution on Silicon:** Executed accumulation loops directly on the Tang Nano 20K, confirming register state `x3 = 0xF` via onboard LEDs.
3. **Pipeline Hazard Stress Test:** Validated consecutive dependent arithmetic instructions and load-use stall insertion in hardware (`x3 = 0xD`).
4. **Physical Serial Output:** Executed machine code issuing `sw` to MMIO address `0x0000_0100`, transmitting ASCII characters over UART (`COM4`) to a PuTTY serial terminal.

---

## Toolchain

- **HDL:** Verilog
- **Simulation:** Icarus Verilog (`iverilog`), GTKWave
- **Synthesis, P&R & Programming:** Gowin EDA (`V1.9.x`), Gowin Programmer
- **Target Board:** Sipeed Tang Nano 20K (`GW2AR-LV18QN88C8/I7`)
```
