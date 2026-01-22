create_library_set -name default_lib_set -timing [list /mnt/c2s/cadence/Digital_tools/FOUNDRY/digital/180nm/dig/lib/typical.lib]
create_rc_corner -name default_rc_corner -preRoute_res 1.0 -preRoute_cap 1.0 -preRoute_clkres 0.0 -preRoute_clkcap 0.0 -postRoute_res 1.0 -postRoute_cap 1.0 -postRoute_xcap 1.0 -postRoute_clkres 0.0 -postRoute_clkcap 0.0
create_delay_corner -name default_delay_corner -library_set default_lib_set -rc_corner default_rc_corner
create_constraint_mode -name default_constraint_mode -sdc_files [list ../cons/constraints.sdc]
create_analysis_view -name default_analysis_view -constraint_mode default_constraint_mode -delay_corner default_delay_corner
set_analysis_view -setup {default_analysis_view} -hold {default_analysis_view}
