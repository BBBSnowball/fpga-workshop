library ieee;
use ieee.std_logic_1164.all;

entity testbench is
end entity;

architecture RTL of testbench is
  signal clk : std_logic := '0';
begin
  DUT : entity work.sevenseg_top
    port map (
      clk => clk,
      buttons => (others => '1'),
      switches => (others => '1')
    );

  clkgen : process
  begin
    wait for 10 ns;
    clk <= not(clk);
  end process;
end architecture;
