create_clock -period 20 [get_ports clk]
set_clock_uncertainty -from [get_clocks clk] 0.1
derive_pll_clocks
derive_clock_uncertainty

set_max_delay  0 -from [get_ports {leds[*] sevenseg_segment[*] sevenseg_digit[*]}]
set_max_delay 10 -to   [get_ports {leds[*] sevenseg_segment[*] sevenseg_digit[*]}]
set_false_path -from [get_ports {rst input dipswitch[*]}]
