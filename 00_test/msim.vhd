library ieee;
use ieee.std_logic_1164.all;

library std;
use std.textio.all;

entity msim_test is
end entity;

architecture tb of msim_test is
  signal clk : std_logic := '0';
  signal stopclk : boolean := false;
begin
  clkgen : process
  begin
    wait for 5 ns;
    clk <= not(clk);
    if stopclk then
      wait;
    end if;
  end process;
  
  hello : process
    variable l : line;
  begin
    wait for 100 ns;
    report "Hello world!" severity note;
    write(l, string'("Hello c3pb!"));
    writeline(output, l);
    stopclk <= true;
    wait;
  end process;
end architecture;
