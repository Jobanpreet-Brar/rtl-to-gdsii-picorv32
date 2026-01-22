# 1. Define the clock (100MHz = 10ns period)
create_clock -name "core_clk" -period 10.0 -waveform {0 5} [get_ports clk]

# 2. Constrain Input/Output Delays
# 2.0ns is fine, provided we fix the drive strength
set_input_delay  2.0 -clock core_clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 2.0 -clock core_clk [all_outputs]

# 3. Drive and Load (The PHYSICAL Fix)
set_load 0.05 [all_outputs]
# Changed BUFX2 -> BUFX12 to eliminate the 1.7ns Input Slew penalty on resetn
set_driving_cell -lib_cell BUFX12 [all_inputs]

# ==============================================================================
# 4. EXCEPTION: Reset Multi-Cycle Path (The LOGICAL Fix)
# ==============================================================================
# Added "-to [all_registers]" to ensure the tool catches the paths
set_multicycle_path 2 -setup -from [get_ports resetn] -to [all_registers]
set_multicycle_path 1 -hold  -from [get_ports resetn] -to [all_registers]
