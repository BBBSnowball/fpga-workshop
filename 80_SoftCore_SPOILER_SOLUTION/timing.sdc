create_clock -period 20 [get_ports clk]
set_clock_uncertainty -to [get_clocks clk] 0.5
set_false_path -from [get_ports {buttons[*] switches[*]}]
set_output_delay -clock clk 5 [get_ports {sevenseg_segment[*] sevenseg_digit[*]}]

set_input_delay  5 -clock altera_reserved_tck [get_ports {altera_reserved_tdi altera_reserved_tms}]
set_output_delay 5 -clock altera_reserved_tck [get_ports {altera_reserved_tdo}]
