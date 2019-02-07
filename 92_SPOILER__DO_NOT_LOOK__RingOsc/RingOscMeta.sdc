create_clock -period 20 [get_ports clk]
set_clock_uncertainty -from [get_clocks clk] 0.1
derive_pll_clocks
derive_clock_uncertainty

#set_input_delay -clock clk 1 [get_ports {rst input dipswitch[*]}]
#set_output_delay -clock clk 1 [get_ports {leds[*] sevenseg_segment[*] sevenseg_digit[*]}]
#set_max_delay 10 -from [get_ports {rst input dipswitch[*]}]
set_max_delay 10 -to   [get_ports {leds[*] sevenseg_segment[*] sevenseg_digit[*]}]
#set_min_delay  0 -from [get_ports {rst input dipswitch[*]}]
set_min_delay  0 -to   [get_ports {leds[*] sevenseg_segment[*] sevenseg_digit[*]}]
set_false_path -from [get_ports {rst input dipswitch[*]}]

#create_clock -period 100 -name fake [get_keepers ringosc_inst|startreg_inst]
#TODO Do we have to report hold if we want the fastest path?
#report_timing -from [get_clocks fake] -detail full_path -panel_name a -npaths 10
#set_false_path -from [get_clocks fake]
