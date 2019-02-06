create_clock -period 20 [get_ports clk]
set_clock_uncertainty -from [get_clocks clk] 0.1
set_input_delay -clock clk 1 [get_ports {rst input}]
set_output_delay -clock clk 1 [get_ports {leds[*] sevenseg_segment[*] sevenseg_digit[*]}]
