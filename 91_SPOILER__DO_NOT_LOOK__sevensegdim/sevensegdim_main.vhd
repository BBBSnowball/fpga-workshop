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

  signal sevenseg_data : tDIGITS_DATA(digits-1 downto 0);
  signal sevenseg_buffer : tDIGITS_BUFFER(1 downto 0) := (others => (others => (others => (others => '0'))));
  signal sevenseg_selector : integer range 0 to 1 := 0;
  signal cnt : unsigned(11 downto 0) := (others => '0');
  signal done : std_logic;
begin
  sevenseg : entity work.sevenseg_array_dim
    port map (clk => clk,
      sevenseg_data => sevenseg_data, sevenseg_segment => sevenseg_segment, sevenseg_digit => sevenseg_digit,
      done => done);

  sevenseg_data <= sevenseg_buffer(1-sevenseg_selector);

  gen : process(clk)
    type tSTATE is (fsmGEN, fsmWAIT_SWAP);
    variable STATE : tSTATE := fsmGEN;
    variable digit : integer range 0 to 7 := 0;
    variable segment : integer range 0 to 7 := 0;
  begin
    if rising_edge(clk) then
      case STATE is
        when fsmGEN =>
          sevenseg_buffer(sevenseg_selector)(digit)(segment) <= xpos(digit, segment) + cnt(cnt'left downto cnt'left-5);

          if segment = 7 and digit = 7 then
            STATE := fsmWAIT_SWAP;
          end if;
          if segment = 7 then
            digit := (digit + 1) mod 8;
          end if;
          segment := (segment + 1) mod 8;
        when fsmWAIT_SWAP =>
          if done = '1' then
            sevenseg_selector <= 1 - sevenseg_selector;
            STATE := fsmGEN;
            cnt <= cnt+1;
          end if;
      end case;
    end if;
  end process;
end architecture;
