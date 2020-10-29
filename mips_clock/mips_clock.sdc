# Quartus SDC constraints

# Constrain the main clock:
create_clock -name "CLOCK_50" -period 20.000ns -waveform {0.0 10.0}  [get_ports {CLOCK_50}]

# Constrain the step by step clock (the period may be more than 80 ns but the waveform must be the same):
#create_clock -name "key(0)" -period 80.000ns -waveform {0.0 10.0} [get_ports {key[0]}]

# Constrain the JTAG clock used by In-System Memory Content Editor, SignalTap or Nios II:
#create_clock -period "30.303 ns" -name {altera_reserved_tck} {altera_reserved_tck}

# Only use one of the clocks at a time:
#set_clock_groups -exclusive -group {CLOCK_50} -group {key(0)}

# Constrain the derived clock:
#create_generated_clock -add -source CLOCK_50 -divide_by 62500 -name CLK_400HZ  [get_pins {CLK_400HZ|q}]
#create_generated_clock -add -source [get_pins {CLK_400HZ|q}] -name CLK_10HZ  [get_pins {CLK_10HZ|q}]
#set_false_path -from [get_pins {CLK_400HZ|q}] -to [get_pins {CLK_10HZ|d}]

# Automatically apply a generate clock on the output of phase-locked loops (PLLs)
# This command can be safely left in the SDC even if no PLLs exist in the design
derive_pll_clocks
derive_clock_uncertainty

# Constrain the input I/O path
set_input_delay -clock CLOCK_50 -max 3 [all_inputs]
set_input_delay -clock CLOCK_50 -min 2 [all_inputs]

# Constrain the output I/O path
set_output_delay -clock CLOCK_50 -max 3 [all_outputs]
set_output_delay -clock CLOCK_50 -min 2 [all_outputs]

# Setting LED outputs as false path, since no timing requirement
#set_false_path -from * -to [get_ports LEDR[*]]

# Setting HEX (7 segments) outputs as false path, since no timing requirement
#set_false_path -from * -to [get_ports HEX0[*]]
#set_false_path -from * -to [get_ports HEX1[*]]
#set_false_path -from * -to [get_ports HEX2[*]]
#set_false_path -from * -to [get_ports HEX3[*]]
#set_false_path -from * -to [get_ports HEX4[*]]
#set_false_path -from * -to [get_ports HEX5[*]]