create_clock -period 20 [get_ports clk]
set_clock_uncertainty -to [get_clocks clk] 0.5
set_false_path -to [get_ports {led*}]
