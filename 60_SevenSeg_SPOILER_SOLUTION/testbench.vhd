library ieee;
use ieee.std_logic_1164.all;

entity testbench is
end entity;

architecture RTL of testbench is
  signal clk : std_logic := '0';
  signal buttons : std_logic_vector(2 to 5) := (others => '1');
begin
  DUT : entity work.sevenseg_top
    port map (
      clk => clk,
      buttons => buttons,
      switches => (others => '1')
    );

  clkgen : process
  begin
    wait for 10 ns;
    clk <= not(clk);
  end process;
  
  test : process
  begin
    wait for 10 us;
    buttons(4) <= '0';
    wait for 1 us;
    buttons(4) <= '1';
    wait;
  end process;
end architecture;
