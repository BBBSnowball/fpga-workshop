foreach f {ring.vhd ring2.vhd testbench.vhd} {
  vcom -work work -2002 -explicit $f
}

vsim work.testbench
configure wave -signalnamewidth 1  ;# show only signal name
add wave sim:/testbench/input sim:/testbench/leds_inv sim:/testbench/leds_on_count
run -all
