# RTL-to-GDSII Implementation: PicoRV32 RISC-V Core (180nm)

![Final Layout](results/Screenshots/Innovus_Full_Chip.png)

## 🚀 Project Overview
This repository contains the complete **RTL-to-GDSII Physical Design flow** for the **PicoRV32**, a size-optimized RISC-V CPU core. The design was implemented using the **Cadence Digital Flow** (Xcelium, Genus, Innovus, Tempus) at the **180nm technology node**.

The project objective was to take a synthesized netlist through the complete PnR flow to achieve a **tapeout-ready database** with clean timing and zero DRC/LVS violations at **100 MHz**.

### 📊 Key Metrics
| Metric | Value | Status |
| :--- | :--- | :--- |
| **Technology** | SCL 180nm | ✅ |
| **Frequency** | **100 MHz** | ✅ Met (Pos Slack) |
| **Gate Count** | ~8,400 Cells | ✅ |
| **Total Power** | **31.44 mW** | ✅ (Static + Dynamic) |
| **Utilization** | ~70% | ✅ |
| **DRC/LVS** | 0 Violations | ✅ Clean |

---

## 🛠️ Design Flow Stages

### 1. Functional Verification (Xcelium)
Before physical implementation, the RTL was verified to ensure the core correctly executes RISC-V instructions.
* **Process:** Compiled the Verilog source and testbench using Cadence Xcelium.
* **Result:** Confirmed correct instruction fetch, decode, and execute behavior.

![Waveforms](results/Screenshots/Verification_Waveforms.png)
*Fig 1: Xcelium waveforms showing successful instruction execution.*

### 2. Logic Synthesis (Genus)
Mapped the generic Verilog RTL to the 180nm standard cell library.
* **Objective:** Translate RTL into a gate-level netlist.
* **Constraints:** Applied standard timing constraints (SDC) with a target clock period of 10ns (100 MHz).
* **Outcome:** Generated a clean gate-level netlist with mapped standard cells.

![Synthesis Schematic](results/Screenshots/Logic_Synthesis_GateLevel.png)
*Fig 2: Gate-level schematic showing standard cell mapping.*

### 3. Floorplanning & Power Planning (Innovus)
This stage defined the chip dimensions and the power distribution network.
* **Core Definition:** Created a square core area with appropriate utilization margins.
* **Power Mesh:** Created a standard **M3/M4 Power Mesh (VDD/VSS)** structure using rings and stripes.

![Power Grid](results/Screenshots/Innovus_Power_Grid.png)
*Fig 3: M3/M4 Power Mesh structure.*

### 4. Placement (Innovus)
Standard cells were placed into the core rows.
* **Execution:** Ran the standard placement command (`place_opt_design`) to place cells and optimize for timing/congestion.
* **Outcome:** Valid placement with no overlaps and acceptable cell density.

![Congestion Map](results/Screenshots/Congestion_Map.png)
*Fig 4: Heat map showing placement congestion (Blue indicates low congestion).*

### 5. Clock Tree Synthesis (CTS)
Built the clock distribution network.
* **Objective:** Distribute the `clk` signal to all sequential elements.
* **Implementation:** Ran the CCOpt (Clock Concurrent Optimization) engine to build a buffered clock tree and meet skew targets.

![Clock Tree](results/Screenshots/Innovus_Clock_Tree.png)
*Fig 5: Visualization of the clock tree.*

### 6. Routing & Signoff
* **Routing:** Completed detailed signal routing using Metal 1 through Metal 6 layers.
* **Physical Verification:** Performed Geometry (DRC) and Connectivity (LVS) checks to ensure manufacturability.

| Detailed Routing | Chip Zoom |
| :---: | :---: |
| ![Routing](results/Screenshots/Innovus_Signals.png) | ![Zoom](results/Screenshots/Innovus_Chip_Zoom.png) |
| *Full Signal Routing* | *Detail View of Standard Cells* |

---

## 📉 Final Analysis Results

### Timing Closure (Tempus)
Static Timing Analysis (STA) was performed to verify the design operates correctly at 100 MHz.
* **Setup Analysis:** **MET**. The design meets the setup time requirements with positive slack.
* **Hold Analysis:** **MET**. Hold violations were fixed during the routing optimization stage.

![Setup Report](results/Screenshots/Tempus_setup.png)
*Fig 6: Final Setup Timing Report showing positive slack.*

### Power Analysis
Total power consumption was analyzed at the Typical corner (1.8V, 25°C).
* **Dynamic Power:** ~8.2 mW
* **Internal Power:** ~23.2 mW
* **Leakage Power:** <1 mW

![Power Report](results/Screenshots/Signoff_Power_Analysis.png)
*Fig 7: Detailed Power Breakdown.*

---

## 📂 Repository Structure
```text
rtl-to-gdsii-picorv32/
├── rtl/                # Verilog Source Code (Core & Wrapper)
├── cons/               # SDC Timing Constraints
├── scripts/            # Tool Scripts (Genus, Innovus, Tempus)
├── pnr/                # Place & Route Logs and Reports
├── results/            # Final GDSII, Netlists, and Spef
│   └── Screenshots/    # Engineering plots and waveforms
└── README.md           # Project Documentation
