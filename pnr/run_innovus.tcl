# =============================================================================
# 1. SETUP & VARIABLES
# =============================================================================
set design "asic_top"
set PDK_PATH "/mnt/c2s/cadence/Digital_tools/FOUNDRY/digital/180nm/dig"

# Input Files
set netlist  "../results/asic_top_netlist.v"
set sdc_file "../cons/constraints.sdc"
set lef_file "$PDK_PATH/lef/all.lef"
set lib_file "$PDK_PATH/lib/typical.lib"

# =============================================================================
# 2. GENERATE MMMC FILE
# =============================================================================
set mmmc_file "viewDefinition.tcl"
set fid [open $mmmc_file w]
puts $fid "create_library_set -name default_lib_set -timing \[list $lib_file\]"
# 180nm Setup
puts $fid "create_rc_corner -name default_rc_corner -preRoute_res 1.0 -preRoute_cap 1.0 -preRoute_clkres 0.0 -preRoute_clkcap 0.0 -postRoute_res 1.0 -postRoute_cap 1.0 -postRoute_xcap 1.0 -postRoute_clkres 0.0 -postRoute_clkcap 0.0"
puts $fid "create_delay_corner -name default_delay_corner -library_set default_lib_set -rc_corner default_rc_corner"
puts $fid "create_constraint_mode -name default_constraint_mode -sdc_files \[list $sdc_file\]"
puts $fid "create_analysis_view -name default_analysis_view -constraint_mode default_constraint_mode -delay_corner default_delay_corner"
puts $fid "set_analysis_view -setup {default_analysis_view} -hold {default_analysis_view}"
close $fid

# =============================================================================
# 3. INITIALIZE DESIGN
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
floorPlan -site tsm3site -r 0.7 0.7 10 10 10 10

# Place Pins (Using get_object_name to prevent pointer errors)
editPin -side Left -layer M3 -spreadType center -pin [get_object_name [get_ports *]]

# =============================================================================
# 5. POWER PLANNING (Grid First Strategy)
# =============================================================================
# Define Global Nets
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *
globalNetConnect VDD -type tiehi -inst *
globalNetConnect VSS -type tielo -inst *

# Build Rings & Stripes
addRing -nets {VDD VSS} -type core_rings -follow core -layer {top M3 bottom M3 left M4 right M4} -width 3 -spacing 1 -offset 1
addStripe -nets {VDD VSS} -layer M4 -direction vertical -width 3 -spacing 1 -set_to_set_distance 50 -start_from left -start_offset 20

# Connect Power (2-Pass to avoid conflicts)
# Pass 1: Rails
sroute -connect { corePin } -layerChangeRange { M1 M6 } -blockPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -allowJogging 1 -crossoverViaLayerRange { M1 M6 } -nets { VDD VSS } -allowLayerChange 1 -targetViaLayerRange { M1 M6 }

# Pass 2: Rings/Stripes
sroute -connect { padPin padRing floatingStripe secondaryPowerPin } -layerChangeRange { M1 M6 } -blockPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -allowJogging 1 -crossoverViaLayerRange { M1 M6 } -nets { VDD VSS } -allowLayerChange 1 -targetViaLayerRange { M1 M6 }

# =============================================================================
# 6. PLACEMENT & CTS
# =============================================================================
place_opt_design

set_ccopt_property -auto_design_state_for_ilms false
create_ccopt_clock_tree_spec
ccopt_design

# =============================================================================
# 8. ROUTING & FINAL OPT (The Fix)
# =============================================================================
# FORCE DISABLE SI AWARENESS to prevent the OCV error
setDelayCalMode -siAware false
setAnalysisMode -analysisType single

# Route
setNanoRouteMode -routeInsertAntennaDiode true
routeDesign

# Optimization (Explicitly disable SI here too just in case)
optDesign -postRoute -setup -hold -drv

# Add Metal Fill
addMetalFill -layer {1 2 3 4 5 6}

# =============================================================================
# 9. VERIFICATION & OUTPUTS
# =============================================================================
puts "--- RUNNING FINAL VERIFICATION ---"
verifyConnectivity -type all -error 1000 -warning 50
verify_drc -limit 1000
verifyProcessAntenna

# Save Final
saveNetlist ../results/asic_top_pr.v -excludeLeafCell
setExtractRCMode -engine postRoute -effortLevel low
extractRC
rcOut -spef ../results/asic_top.spef -rc_corner default_rc_corner
streamOut ../results/final_layout.gds -units 1000 -mode ALL
saveDesign ../results/final_design_golden.enc

puts "--------------------------------------------------------"
puts "  INNOVUS RUN COMPLETE"
puts "--------------------------------------------------------"
exit
