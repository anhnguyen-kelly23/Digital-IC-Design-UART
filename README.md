# UART IP Core Design and Physical Implementation

## 1. Overview
This project implements a **Universal Asynchronous Receiver-Transmitter (UART)** IP core using Verilog HDL, followed by a complete Digital IC Design flow from RTL to physical layout.

The design enables asynchronous serial communication between two devices without requiring a shared clock, using standard TX/RX signaling.

---

## 2. Key Features
- Full UART TX/RX implementation
- Configurable data frame:
  - 1 start bit
  - 7–8 data bits
  - Optional parity bit
  - 1–2 stop bits
- Serial-to-parallel and parallel-to-serial conversion
- Mid-bit sampling for reliable data reception
- Verified through both simulation and backend flow

---

## 3. Design Flow

### RTL Design & Simulation
- Language: Verilog HDL
- Modules:
  - `UART_TX`
  - `UART_RX`
  - `TOP`
- Tools:
  - Synopsys VCS
  - ModelSim
- Verified with multiple test scenarios

### Logic Synthesis
- Tool: Synopsys Design Compiler
- Analysis:
  - Area report
  - QoR (Quality of Results)
- Comparison between pre-synthesis and post-synthesis

### Physical Design
- Flow:
  - Floorplanning
  - Placement
  - Clock Tree Synthesis (CTS)
  - Routing
- Verification:
  - DRC (Design Rule Check)
  - LVS (Layout vs Schematic)

### Formal Verification
- Tool: Synopsys Formality
- Ensures equivalence between RTL and synthesized netlist

---

## 4. Project Structure
├── src/ # Verilog source code (UART_TX, UART_RX, TOP)
├── testbench/ # Simulation testbench and test cases

---

## 5. How to Run

### Simulation
- Run testbench using ModelSim or VCS
- Verify TX/RX functionality with provided test cases

### Synthesis
- Use Synopsys Design Compiler
- Analyze timing, area, and QoR reports

### Physical Design
- Run backend flow (ICC or equivalent tools)
- Perform DRC, LVS, and generate final layout

---

## 6. Applications
- FPGA-based communication systems
- Embedded systems
- Serial interface design
- Digital IC design education

---

## 7. Authors
- Nguyen Minh Anh  
- Tran Hoang Anh  
VNUHCM - University of Science
