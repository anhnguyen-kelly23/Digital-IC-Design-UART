# UART IP Core Design and Physical Implementation (Course Project)

## 1. Project Overview
[cite_start]This project focuses on the design and physical implementation of a **Universal Asynchronous Receiver-Transmitter (UART)** controller[cite: 3]. [cite_start]The system enables asynchronous serial communication between two devices (1 Master - 1 Slave) without a shared clock signal[cite: 11, 12].

## 2. Technical Specifications
* [cite_start]**Architecture:** 1:1 communication model using TX and RX lines[cite: 12, 15].
* [cite_start]**Data Frame:** 1 start bit (logic 0), 7-8 data bits, 1 optional parity bit, and 1-2 stop bits (logic 1)[cite: 19].
* [cite_start]**Sampling:** Data is sampled at the center of the bit pulse for accuracy[cite: 20].
* [cite_start]**Data Conversion:** Serial-to-parallel and parallel-to-serial conversion[cite: 16].

## 3. Implementation Flow
The project follows the standard Digital IC Design flow using industrial EDA tools:

### RTL Design & Simulation
* [cite_start]**HDL:** Verilog HDL for `UART_TX`, `UART_RX`, and `TOP` modules[cite: 24, 28, 22].
* [cite_start]**Tools:** Functional verification performed using **VCS** and **ModelSim**[cite: 34, 38].
* [cite_start]**Validation:** Verified with multiple test scenarios (TESTDATA_1 and TESTDATA_2)[cite: 38, 42].

### Logic Synthesis
* [cite_start]**Tool:** **Synopsys Design Tools**.
* [cite_start]**Analysis:** Evaluated design through **Report Area** and **Report QoR** (Quality of Results) for both Pre-Synthesis and Post-Synthesis stages[cite: 46, 50, 54].

### Physical Design & Verification
* [cite_start]**Placement & Routing:** Executed the back-end flow including **Post-Placement** and **Post-Routing** stages[cite: 62, 68].
* [cite_start]**Sign-off Checks:** Performed **DRC (Design Rule Check)** and **LVS (Layout Vs Schematic)** to ensure physical integrity[cite: 70, 72].
* [cite_start]**Result:** Generated the final **Layout** through the tool flow[cite: 74].
* [cite_start]**Formal Verification:** Used **Formality** to verify logical equivalence between RTL and the Physical Design[cite: 58, 76].

## 4. Repository Structure
* [cite_start]`/src`: Contains Verilog source code[cite: 22, 24, 28].
* [cite_start]`/testbench`: Contains simulation files and testbench[cite: 32].
* [cite_start]`/docs`: Technical presentation and documentation[cite: 1].

---
[cite_start]*Developed by: Nguyễn Minh Anh & Trần Hoàng Anh (VNUHCM-US)*[cite: 5, 6].
