library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity ringosc is
  generic (
    num_lut : integer := 10
  );
  port (
    enable : in  std_logic := '1';
    clk    : out std_logic
  );
end entity;

library altera_mf; 
use altera_mf.altera_mf_components.all;
library altera;
use altera.altera_primitives_components.all;

architecture RTL of ringosc is
  signal ring : std_logic_vector(num_lut-1 downto 0);
  signal startreg : std_logic;
  
  attribute preserve : boolean;
  attribute preserve of startreg : signal is true;
  attribute preserve of startreg_inst : label is true;
begin
  -- inspired by https://fpgawiki.intel.com/wiki/Ring_Oscillator

  genring : for i in 1 to num_lut-1 generate
    buf : LCELL port map (a_in => ring(i-1), a_out => ring(i));
  end generate;

	startreg_inst : DFF
	port map (
			d => '0', 
			clk => '0', 
			clrn => '1',
			prn => '1',
			q => startreg
	);
  
  ring(0) <= enable and not(ring(num_lut-1) xor startreg);

  clk <= ring(num_lut-1);

  assert num_lut > 3 report "Please make sure you don't violate Fmax!" severity error;
end architecture;
