library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity top is
  port (
    clk : in std_logic;
    sevenseg_segment : out std_logic_vector(7 downto 0);
    sevenseg_digit   : out std_logic_vector(8-1 downto 0)
  );
end entity top;

architecture RTL of top is
  signal sevenseg_data : unsigned(8*8*8-1 downto 0);
  signal cnt : unsigned(10 downto 0) := (others => '0');
  signal done : std_logic;

  -- NOTE: This is not really gamma, but serves the same purpose.
  -- see https://www.mikrocontroller.net/articles/LED-Fading#FAQ
  constant gamma : real := 2.0; -- -1.0;
  function apply_gamma(input : unsigned; len : integer) return unsigned is
    constant max   : integer := 2**len-1;
    constant steps : integer := 2**input'length-1;
    constant b     : real    := (real(max)/gamma)**(1.0/(real(steps-1)));
  begin
    if input = (input'range => '0') then
      return to_unsigned(0, len);
    elsif gamma < 0.0 then
      return input & to_unsigned(0, len-input'length);
    else
      return to_unsigned(integer(round(gamma * b ** real(to_integer(input)))), len);
    end if;
  end function;
begin
  sevenseg : entity work.sevenseg_array_dim
    generic map (digits => 8, depth => 8)
    port map (clk => clk,
      sevenseg_data => sevenseg_data, sevenseg_segment => sevenseg_segment, sevenseg_digit => sevenseg_digit,
      done => done);
  
  gen : process(clk)
    procedure set_digit(digit, segment : integer; data : unsigned(7 downto 0)) is
    begin
      sevenseg_data(digit*8*8+segment*8+8-1 downto digit*8*8+segment*8) <= data;
    end procedure;

    function xpos(digit, segment : integer) return integer is
    begin
      case segment is
        when 4 | 5     => return 0 + 4*(7-digit);
        when 0 | 3 | 6 => return 1 + 4*(7-digit);
        when 1 | 2     => return 2 + 4*(7-digit);
        when others    => return 3 + 4*(7-digit);
      end case;
    end function;

    function ypos(digit, segment : integer) return integer is
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
  begin
    if rising_edge(clk) then
      for digit in 0 to 7 loop
        for segment in 0 to 7 loop
          --set_digit(digit, segment, (to_unsigned(digit, 3) & to_unsigned(segment, 3) & "00") + cnt(cnt'left downto cnt'left-7));
          --set_digit(digit, segment, to_unsigned(xpos(digit, segment)*256/32, 8));
          set_digit(digit, segment, apply_gamma(to_unsigned(xpos(digit, segment), 5), 8));
          --set_digit(digit, segment, apply_gamma(to_unsigned(xpos(digit, segment), 5) + cnt(cnt'left downto cnt'left-4), 8));
        end loop;
      end loop;

      if done='1' then
        cnt <= cnt+1;
      end if;
    end if;
  end process;
end architecture;
