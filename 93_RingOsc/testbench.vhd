library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity;

architecture TB of testbench is
  signal clk1, clk2, rst, input : std_logic := '0';
  signal leds, leds_inv : std_logic_vector(3 to 14);
  signal leds_on_count : integer;
  signal stopclk : boolean := false;
begin
  DUT : entity work.ring2
    generic map (
      sel_input => 1,
      sel_sync  => 0
    )
    port map (
      clk_ring    => clk1,
      clk_ringosc => clk2,
      rst         => rst,
      pll_locked  => '1',
      input       => input,
      leds        => leds
    );

  clkgen1 : process
  begin
    wait for 3 ns;
    clk1 <= '1';
    wait for 2 ns;
    clk1 <= '0';
    if stopclk then wait; end if;
  end process;

  clkgen2 : process
  begin
    wait for 20 ns;
    clk2 <= not(clk2);
    if stopclk then wait; end if;
  end process;
  
  test : process
  begin
    rst <= '0';
    input <= '1';
    wait for 50 ns;
    rst <= '1';
    wait for 500 ns;
    for i in 1 to 10 loop
      input <= '0';
      wait for 500 ns;
      input <= '1';
      wait for 500 ns;
    end loop;
    stopclk <= true;
    wait;
  end process;
  
  leds_inv <= not(leds);

  count : process(leds)
    variable cnt : integer;
  begin
    cnt := 0;
    for i in leds'range loop
      if leds(i) = '0' then
        cnt := cnt + 1;
      end if;
    end loop;
    leds_on_count <= cnt;
  end process;
end architecture;