#!/bin/bash
# https://wiki.archlinux.org/index.php/Altera_Design_Software#With_freetype2_2.5.0.1-1
D="$(dirname "$0")"
# I have patched ./bin/vsim to call the binary in "linux" instead of "linux_rh60"
# but we can directly start the right binary and avoid that.
LD_LIBRARY_PATH="$D/libs" "$D/linux/vsim"
