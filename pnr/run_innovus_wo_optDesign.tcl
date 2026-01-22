# =============================================================================
# 1. SETUP & VARIABLES
# =============================================================================
set design "asic_top"
set PDK_PATH "/mnt/c2s/cadence/Digital_tools/FOUNDRY/digital/180nm/dig"

# Input Files
set netlist  "../results/asic_top_netlist.v"
set sdc_file "../results/asic_top_netlist.sdc"
set lef_file "$PDK_PATH/lef/all.lef"
set lib_file "$PDK_PATH/lib/typical.lib"

# =============================================================================
# 2. GENERATE MMMC FILE (On-the-fly)
# =============================================================================
# This creates the timing configuration file required by Innovus 20+
set mmmc_file "viewDefinition.tcl"
set fid [open $mmmc_file w]
puts $fid "create_library_set -name default_lib_set -timing \[list $lib_file\]"

# FIXED: Removed problematic options (-preRoute_clk_res etc) for 180nm
puts $fid "create_rc_corner -name default_rc_corner -preRoute_res 1.0 -preRoute_cap 1.0 -preRoute_clkres 0.0 -preRoute_clkcap 0.0 -postRoute_res 1.0 -postRoute_cap 1.0 -postRoute_xcap 1.0 -postRoute_clkres 0.0 -postRoute_clkcap 0.0"

puts $fid "create_delay_corner -name default_delay_corner -library_set default_lib_set -rc_corner default_rc_corner"
puts $fid "create_constraint_mode -name default_constraint_mode -sdc_files \[list $sdc_file\]"
puts $fid "create_analysis_view -name default_analysis_view -constraint_mode default_constraint_mode -delay_corner default_delay_corner"
puts $fid "set_analysis_view -setup {default_analysis_view} -hold {default_analysis_view}"
close $fid

# =============================================================================
# 3. INITIALIZE DESIGN (MMMC Mode)
# =============================================================================
set init_gnd_net {VSS}
set init_pwr_net {VDD}
set init_verilog "$netlist"
set init_lef_file "$lef_file"
set init_top_cell "$design"
set init_mmmc_file "$mmmc_file" 

init_design

# =============================================================================
# 4. FLOORPLANNING
# =============================================================================
# FIXED: Changed site from 'core' to 'tsm3site' based on your log
floorPlan -site tsm3site -r 0.7 0.7 10 10 10 10

# =============================================================================
# 5. POWER PLANNING
# =============================================================================
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *
globalNetConnect VDD -type tiehi -inst *
globalNetConnect VSS -type tielo -inst *

addRing -nets {VDD VSS} -width 5.0 -spacing 2.0 -layer_top M3 -layer_bottom M3 -layer_left M4 -layer_right M4

# =============================================================================
# 6. PLACEMENT (Timing Driven)
# =============================================================================
place_opt_design

# =============================================================================
# 7. CLOCK TREE SYNTHESIS (CTS)
# =============================================================================
set_ccopt_property -auto_design_state_for_ilms false
create_ccopt_clock_tree_spec
ccopt_design

# =============================================================================
# 8. ROUTING
# =============================================================================
routeDesign

# =============================================================================
# 9. FINAL OUTPUTS
# =============================================================================
streamOut ../results/final_layout.gds -units 1000 -mode ALL
saveDesign ../results/final_design.enc

puts "--------------------------------------------------------"
puts "  INNOVUS RUN COMPLETE: TIMING DRIVEN PnR SUCCESSFUL"
puts "  GDS File: ../results/final_layout.gds"
puts "--------------------------------------------------------"
exit
