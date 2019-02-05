library ieee;
use ieee.std_logic_1164.all;

entity SimpleVhdl is
  port (
    dip1, dip2, dip3, dip4, dip5, dip6, dip7, dip8, button_k5 : in std_logic;
    led_d3, led_d4, led_d5, led_d6, led_d7, led_d8 : out std_logic
  );
end entity;

architecture RTL of SimpleVhdl is
begin
  comb_example : process(dip1, dip2, dip3, dip4)
  begin
    led_d3 <= dip1 and dip2 and dip3;
    led_d5 <= '1';
    led_d6 <= dip4;
  end process;

  led_d4 <= dip1 or  dip2 or  dip3;

  clocked_example : process(button_k5)
  begin
    if rising_edge(button_k5) then
      led_d7 <= dip1 and dip2 and dip3;
      led_d8 <= dip1 or  dip2 or  dip3;
    end if;
  end process;
end architecture;
