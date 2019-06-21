library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blink is
  port (
    clk : in std_logic;
    --dip1, dip2, dip3, dip4, dip5, dip6, dip7, dip8 : in std_logic;
    --leds : out std_logic_vector(3 to 14)
    leds : out std_logic_vector(3 to 3)
  );
end entity;

architecture RTL of blink is
  signal cnt : unsigned(31 downto 0);
begin
  process(clk)
  begin
    if rising_edge(clk) then
      cnt <= cnt + 1;
    end if;
  end process;
  
  leds(3) <= cnt(24);
  --leds(4 to 14) <= (others => '1');
end architecture;
