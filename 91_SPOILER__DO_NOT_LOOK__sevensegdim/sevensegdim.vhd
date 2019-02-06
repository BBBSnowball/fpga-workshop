library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sevenseg_array_dim is
  generic (
    digits : integer;
    clkdiv : integer := 12;
    depth  : integer := 1
  );
  port (
    clk : in std_logic;
    sevenseg_data    : in  unsigned(digits*8*depth-1 downto 0);
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
            if depth <= 1 then
              sevenseg_segment(i) <= std_logic(not(sevenseg_data(digit_index*8*depth+i*depth)));
            elsif sevenseg_data(digit_index*8*depth+i*depth+depth-1 downto digit_index*8*depth+i*depth) > cnt(cnt'left-1 downto cnt'left-depth) then
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
