vcom msim.vhd
vsim work.msim_test
add wave /msim_test/clk /msim_test/stopclk
view wave
run -all
