catch {vlib work}
vcom sevenseg.vhd sevenseg_top.vhd testbench.vhd
vsim work.testbench
configure wave -signalnamewidth 1  ;# show only signal name
add wave /testbench/clk /testbench/DUT/sevenseg_segment /testbench/DUT/sevenseg_digit
view wave
run 1 us
