#!/bin/bash

# ---------------------------------------------------------
# Xcelium Simulation Wrapper Script
# Usage: 
#   ./run_sim.sh        (Batch Mode - Generates Log)
#   ./run_sim.sh -gui   (Debug Mode - Opens SimVision)
# ---------------------------------------------------------

# 1. Cleanup previous run data
#    Only clean if NOT in GUI mode to avoid deleting waves while looking at them
if [[ "$1" != "-gui" ]]; then
    echo "[FLOW] Cleaning up previous simulation data..."
    rm -rf xrun.log xrun.history xcelium.d waves.shm
fi

# 2. Define File Paths
RTL_FILES="../rtl/picorv32.v ../rtl/asic_top.v"
TB_FILE="../tb/tb_top.sv"

# 3. Handle GUI vs Batch Mode
GUI_FLAG=""
INPUT_SCRIPT="run_xrun.tcl"

if [[ "$1" == "-gui" ]]; then
    echo "[FLOW] GUI Mode detected. Launching SimVision..."
    GUI_FLAG="-gui"
    
    # Create a temp script that doesn't exit automatically
    grep -v "exit" run_xrun.tcl > run_gui.tcl
    INPUT_SCRIPT="run_gui.tcl"
else
    echo "[FLOW] Batch Mode. Running simulation..."
fi

# 4. Launch Xcelium
xrun \
  -64bit \
  -sv \
  -access +rwc \
  $GUI_FLAG \
  -input $INPUT_SCRIPT \
  $RTL_FILES \
  $TB_FILE \
  -l xrun.log

# 5. Cleanup temp file
if [[ -f "run_gui.tcl" ]]; then
    rm run_gui.tcl
fi

echo "[FLOW] Done."
