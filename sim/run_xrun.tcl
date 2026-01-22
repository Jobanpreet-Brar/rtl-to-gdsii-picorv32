# ---------------------------------------------------------
# Xcelium Runtime Control Script
# Loaded by: xrun -input run_xrun.tcl
# ---------------------------------------------------------

# 1. Setup Waveform Database (SHM Format)
database -open waves -into waves.shm -default

# 2. Probe Signals
#    -create    : Adds signals to the database
#    -depth all : Captures Top Module + All Sub-modules (ALU, Regs, etc.)
#    -all       : Captures Inputs, Outputs, and Internal wires
#    -mem       : Captures Memory arrays (Register File)
probe -create -shm -all -depth all -mem

# 3. Run Simulation
#    Runs until the testbench executes '$finish'
run
