library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sevenseg.all;

entity sevenseg_top is
  port (
    clk : in std_logic;
    buttons : in std_logic_vector(2 to 5);
    switches : in std_logic_vector(1 to 8);
    sevenseg_segment : out std_logic_vector(7 downto 0);
    sevenseg_digit   : out std_logic_vector(7 downto 0)
  );
end entity sevenseg_top;

architecture RTL of sevenseg_top is
  signal cnt : std_logic_vector(35 downto 0) := (others => '0');
  signal sevenseg_data : std_logic_vector(63 downto 0) := (0 => '1', others => '0');
begin
  p : process(clk)
  begin
    if rising_edge(clk) then
      cnt <= std_logic_vector(unsigned(cnt)+1);
    end if;
  end process;

  sevenseg_display: sevenseg_flat
    generic map (digits => 8)
    port map (
      clk => clk,
      sevenseg_data => sevenseg_data,
      sevenseg_segment => sevenseg_segment,
      sevenseg_digit => sevenseg_digit
    );
  gen_sevenseg: process(clk)
  begin
    if rising_edge(clk) then
      if to_integer(unsigned(cnt(22 downto 0))) = 0 then
        sevenseg_data <= sevenseg_data(sevenseg_data'left-1 downto 0) & sevenseg_data(sevenseg_data'left);
      end if;

      if buttons(3)='0' then
        sevenseg_data <= x"ffffffffffffffff";
      end if;

      if buttons(4)='0' then
        sevenseg_data <= x"8040201008040201";
      end if;
    end if;
  end process;
end architecture;
