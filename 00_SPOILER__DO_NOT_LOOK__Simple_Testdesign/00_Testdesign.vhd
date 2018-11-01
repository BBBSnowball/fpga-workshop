library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testdesign is
  port (
    clk : in std_logic;
    led5 : out std_logic
  );
end entity testdesign;

architecture RTL of testdesign is
  signal cnt : std_logic_vector(25 downto 0);
begin
  p : process(clk)
  begin
    if rising_edge(clk) then
      cnt <= std_logic_vector(unsigned(cnt)+1);
    end if;
  end process;
  
  led5 <= cnt(cnt'high);
end architecture;
