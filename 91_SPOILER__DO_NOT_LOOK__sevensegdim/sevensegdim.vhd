library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package sevenseg_dim is
  constant digits : integer := 8;
  constant segments_per_digit : integer := 8;

  constant pwm_depth : integer := 12;
  constant color_depth : integer := 6;  -- before gamma correction
  
  subtype tSEGMENT_DATA is unsigned(color_depth-1 downto 0);
  type tDIGIT_DATA is array(integer range <>) of tSEGMENT_DATA;
  type tDIGITS_DATA is array(integer range <>) of tDIGIT_DATA(segments_per_digit-1 downto 0);

  -- NOTE: This is not really gamma, but serves the same purpose.
  -- see https://www.mikrocontroller.net/articles/LED-Fading#FAQ
  constant gamma : real := 2.0; -- -1.0;

  function apply_gamma(input : unsigned; len : integer) return unsigned;

  type tGAMMA_TABLE is array(integer range <>) of unsigned(pwm_depth-1 downto 0);

  function init_gamma_table return tGAMMA_TABLE;

  constant gamma_table : tGAMMA_TABLE(2**color_depth-1 downto 0) := init_gamma_table;
end package;

package body sevenseg_dim is
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

  function init_gamma_table return tGAMMA_TABLE is
    variable t : tGAMMA_TABLE(2**color_depth-1 downto 0);
  begin
    for i in t'range loop
      t(i) := apply_gamma(to_unsigned(i, color_depth), pwm_depth);
    end loop;
    return t;
  end function;
end package body;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sevenseg_dim.all;

entity sevenseg_array_dim is
  generic (
    clkdiv : integer := 12
  );
  port (
    clk : in std_logic;
    sevenseg_data    : in  tDIGITS_DATA(digits-1 downto 0);
    sevenseg_segment : out std_logic_vector(7 downto 0);
    sevenseg_digit   : out std_logic_vector(digits-1 downto 0);
    done             : out std_logic
  );
end entity sevenseg_array_dim;

architecture RTL of sevenseg_array_dim is
  type tState is (fsmINIT, fsmSWITCH_TO, fsmDISPLAY, fsmSWITCH_FROM);
  signal state : tState := fsmINIT;
  signal cnt : unsigned(clkdiv downto 0);
  subtype tDIGIT_INDEX is integer range 0 to digits-1;
  signal digit_index : tDIGIT_INDEX := 0;
begin
  fsm: process(clk)
  begin
    if rising_edge(clk) then
      done <= '0';
      case state is
        when fsmINIT =>
          digit_index <= 0;
          state <= fsmSWITCH_TO;

          sevenseg_digit <= (others => '1');
          sevenseg_segment <= (others => '1');
        when fsmSWITCH_TO =>
          state <= fsmDISPLAY;
          cnt <= (others => '0');

          sevenseg_digit <= (others => '1');
          sevenseg_digit(digit_index) <= '0';
          sevenseg_segment <= (others => '1');
        when fsmDISPLAY =>
          if cnt(cnt'left) = '1' then
            state <= fsmSWITCH_FROM;
          end if;
          cnt <= cnt + 1;

          sevenseg_digit <= (others => '1');
          sevenseg_digit(digit_index) <= '0';
          for i in 0 to 7 loop
            if pwm_depth <= 1 then
              sevenseg_segment(i) <= std_logic(not(sevenseg_data(digit_index)(i)(0)));
            elsif gamma_table(to_integer(sevenseg_data(digit_index)(i)))
                > cnt(cnt'left-1 downto cnt'left-pwm_depth) then
              sevenseg_segment(i) <= '0';
            else
              sevenseg_segment(i) <= '1';
            end if;
          end loop;
        when fsmSWITCH_FROM =>
          state <= fsmSWITCH_TO;
          if digit_index < digits-1 then
            digit_index <= digit_index + 1;
          else
            digit_index <= 0;
            done <= '1';
          end if;

          sevenseg_digit <= (others => '1');
          sevenseg_digit(digit_index) <= '0';
          sevenseg_segment <= (others => '1');
      end case;
    end if;
  end process;
end architecture;
