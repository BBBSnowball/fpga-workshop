library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.sevenseg_dim.all;

entity top is
  port (
    clk : in std_logic;
    sevenseg_segment : out std_logic_vector(7 downto 0);
    sevenseg_digit   : out std_logic_vector(8-1 downto 0)
  );
end entity top;

architecture RTL of top is
  signal sevenseg_data : tDIGITS_DATA(digits-1 downto 0);
  signal cnt : unsigned(11 downto 0) := (others => '0');
  signal done : std_logic;
begin
  sevenseg : entity work.sevenseg_array_dim
    port map (clk => clk,
      sevenseg_data => sevenseg_data, sevenseg_segment => sevenseg_segment, sevenseg_digit => sevenseg_digit,
      done => done);
  
  gen : process(clk)
    function xpos_int(digit, segment : integer) return integer is
    begin
      case segment is
        when 4 | 5     => return 0 + 4*(digits-1-digit);
        when 0 | 3 | 6 => return 1 + 4*(digits-1-digit);
        when 1 | 2     => return 2 + 4*(digits-1-digit);
        when others    => return 3 + 4*(digits-1-digit);
      end case;
    end function;

    function ypos_int(digit, segment : integer) return integer is
    begin
      case segment is
        when 0 => return 4;
        when 1 => return 3;
        when 2 => return 1;
        when 3 => return 0;
        when 4 => return 1;
        when 5 => return 3;
        when 6 => return 2;
        when 7 => return 0;
        when others => return 0;
      end case;
    end function;

    function xpos(digit, segment : integer) return unsigned is
    begin
      return to_unsigned(xpos_int(digit, segment), 5);
    end function;

    function ypos(digit, segment : integer) return unsigned is
    begin
      return to_unsigned(ypos_int(digit, segment), 3);
    end function;
  begin
    if rising_edge(clk) then
      for digit in 0 to 7 loop
        for segment in 0 to 7 loop
          sevenseg_data(digit)(segment) <= xpos(digit, segment) + cnt(cnt'left downto cnt'left-5);
        end loop;
      end loop;

      if done='1' then
        cnt <= cnt+1;
      end if;
    end if;
  end process;
end architecture;
