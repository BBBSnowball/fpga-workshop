create_clock -period 20 [get_ports clk]
set_clock_uncertainty -from [get_clocks clk] 0.1
derive_pll_clocks
derive_clock_uncertainty

set_max_delay 10 -to   [get_ports {leds[*]}]
set_min_delay  0 -to   [get_ports {leds[*]}]
set_false_path -from [get_ports {rst input}]
