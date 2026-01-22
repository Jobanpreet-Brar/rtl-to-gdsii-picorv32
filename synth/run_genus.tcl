# =============================================================================
# 1. SETUP LIBRARIES & PATHS
# =============================================================================
set PDK180 "/mnt/c2s/cadence/Digital_tools/FOUNDRY/digital/180nm/dig"
set LIB_TYP "$PDK180/lib/typical.lib"

# Set search paths for RTL
set_db / .hdl_search_path {../rtl}

# Load the library (using typical only for fastest setup)
set_db / .library $LIB_TYP

# =============================================================================
# 2. READ AND ELABORATE
# =============================================================================
# Note: Ensure both files exist in ../rtl/
read_hdl {picorv32.v asic_top.v}

# Elaborate the TOP wrapper, NOT the raw picorv32 module
elaborate asic_top

# =============================================================================
# 3. CONSTRAINTS
# =============================================================================
read_sdc ../cons/constraints.sdc

# =============================================================================
# 4. SYNTHESIS STEPS
# =============================================================================
syn_generic
syn_map
syn_opt

# =============================================================================
# 5. OUTPUTS
# =============================================================================
report_qor > ../results/synth_qor.rpt
report_area > ../results/synth_area.rpt
report_timing > ../results/synth_timing.rpt

# Write netlist for Innovus
write_hdl > ../results/asic_top_netlist.v
write_sdc > ../results/asic_top_netlist.sdc

puts "GENUS SYNTHESIS COMPLETE. CHECK ../results/ FOR NETLIST."
exit
