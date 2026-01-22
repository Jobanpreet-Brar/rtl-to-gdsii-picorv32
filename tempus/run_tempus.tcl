# =============================================================================
# 1. SETUP VARIABLES
# =============================================================================
set design "asic_top"
set PDK_PATH "/mnt/c2s/cadence/Digital_tools/FOUNDRY/digital/180nm/dig"

# Files
set netlist  "../results/asic_top_pr.v"
set spef     "../results/asic_top.spef"
set sdc      "../cons/constraints.sdc"
set lib_file "$PDK_PATH/lib/typical.lib"

# =============================================================================
# 2. GLOBAL SETTINGS (The Fix)
# =============================================================================
# Corrected syntax: Use standard 'set' for this variable
set load_netlist_ignore_undefined_cell true

# =============================================================================
# 3. LOAD DESIGN
# =============================================================================
# 1. Read the Timing Library
read_lib $lib_file

# 2. Read the Physical Netlist
read_verilog $netlist

# 3. Link the design hierarchy
set_top_module $design

# =============================================================================
# 4. LOAD PARASITICS & CONSTRAINTS
# =============================================================================
# 4. Read the Wire Parasitics (SPEF)
read_spef $spef

# 5. Read the Timing Constraints
read_sdc $sdc

# =============================================================================
# 5. TIMING ANALYSIS
# =============================================================================
# Set analysis mode to Single (Typical corner only)
set_analysis_mode -analysisType single

# Build the timing graph
update_timing -full

# =============================================================================
# 6. REPORTS
# =============================================================================
puts "--------------------------------------------------------"
puts "  GENERATING TIMING REPORTS"
puts "--------------------------------------------------------"

# Report Setup (Max) Timing
report_timing -path_type full_clock -max_paths 10 -nworst 1 > tempus_setup.rpt

# Report Hold (Min) Timing
report_timing -early -path_type full_clock -max_paths 10 -nworst 1 > tempus_hold.rpt

# High-level summary
report_analysis_summary > tempus_summary.rpt

puts "TEMPUS RUN COMPLETE. Check 'tempus_setup.rpt' for the final slack."
exit
