library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SimpleVhdl2 is
  port (
    dip1, dip2, dip3, dip4, dip5, dip6, dip7, dip8, button_k5 : in std_logic;
    clk : in std_logic;
    led_d3, led_d4, led_d5, led_d6, led_d7, led_d8 : out std_logic;
    leds : out std_logic_vector(9 to 14)
  );
end entity;

architecture RTL of SimpleVhdl2 is
  signal counter : unsigned(28 downto 0) := (others => '0');
begin
  comb_example : process(dip1, dip2, dip3, dip4)
  begin
    led_d3 <= dip1 and dip2 and dip3;
    led_d4 <= dip1 or  dip2 or  dip3;
    led_d5 <= '1';
    led_d6 <= dip4;
  end process;

  clocked_example : process(button_k5)
  begin
    if rising_edge(button_k5) then
      led_d7 <= dip1 and dip2 and dip3;
      led_d8 <= dip1 or  dip2 or  dip3;
    end if;
  end process;

  blink : process(clk)
  begin
    if rising_edge(clk) then
      counter <= counter + 1;
    end if;
  end process;
  
  leds(9) <= std_logic(counter(counter'left));    -- counter(28)
  leds(10 to 12) <= std_logic_vector(counter(counter'left-1 downto counter'left-3));
  leds(13) <= '0';
  leds(14) <= '1';
end architecture;
