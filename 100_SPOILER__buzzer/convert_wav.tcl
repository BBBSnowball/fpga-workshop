#!/usr/bin/env tclsh8

# see http://truelogic.org/wordpress/2015/09/04/parsing-a-wav-file-in-c/

set f [open "nootnoot01a.wav" rb]
set data [read $f 44]
binary scan $data a4iua7x1iususuiuiususua4iu sig1 filesize sig2 fmtlen fmttype channels samplerate bytes_per_second bytes_per_sample bits_per_sample sig4 filesize2
#NOTE The page linked above claims that there should be '\0' after 'fmt' but it is ' ' - I'm ignoring this, for now.
if {$sig1 ne "RIFF" || $sig2 ne "WAVEfmt"} {
  error "Unexpected signature in wav file"
}
seek $f 0 end
if {[tell $f] != $filesize+8} {
  error "File size in header is $filesize+8 but real size is [tell $f]."
}
if {$fmtlen != 16} {
  error "Unexpected length for 'fmt' header; is $fmtlen, should be 16."
}
if {$fmttype != 1 || $channels != 1 || $samplerate != 44100 || $bits_per_sample != 16} {
  error "Format is not PCM, 1 channel, 44100 Hz, 16 bit."
}
if {$bytes_per_sample != $bits_per_sample*$channels/8 || $bytes_per_second != $samplerate * $bytes_per_sample} {
  error "Inconsistent value for bytes per sample resp. second: Expected $bytes_per_sample == $bits_per_sample*$channels/8 and $bytes_per_second == $samplerate * $bytes_per_sample"
}
# It is smaller than remainder of the file, because there is some tag info at the end (artist, title, etc).
if {$filesize2 > $filesize - 44} {
  error "Data length too big."
}
seek $f 44
set data [read $f $filesize2]
close $f

set f2 [open "pcmdata.vhd" w]
puts $f2 [string map [list %cnt% [expr {$filesize2/2}]] {
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pcmdata is
  type tSAMPLES is array(integer range <>) of signed(7 downto 0);
  constant pcmsamples : tSAMPLES(0 to %cnt%) := (
}]

for {set i 0} {$i<$filesize2} {incr i 2} {
  binary scan [string range $data $i $i+1] s sample
  puts $f2 "    to_signed([expr {$sample/256}], 8),"
}
puts $f2 {
    to_signed(0, 8)
  );
end package;
}
close $f2
