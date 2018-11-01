create_clock -period 20 [get_ports clk]
set_clock_uncertainty -to [get_clocks clk] 0.5
set_false_path -from [get_ports {buttons[*] switches[*]}]
set_false_path -to [get_ports {leds[*]}]
set_output_delay -clock clk 5 [get_ports {bell}]
set_input_delay  -clock clk 5 [get_ports {uart_rx}]
set_output_delay -clock clk 5 [get_ports {uart_tx}]
set_output_delay -clock clk 5 [get_ports {sevenseg_segment[*] sevenseg_digit[*]}]
