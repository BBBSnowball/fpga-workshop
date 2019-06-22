library ieee;
use ieee.std_logic_1164.all;

package sevenseg is
  component sevenseg_flat is
    generic (
      digits : integer;
      clkdiv : integer := 12
    );
    port (
      clk : in std_logic;
      sevenseg_data    : in  std_logic_vector(8*digits-1 downto 0);
      sevenseg_segment : out std_logic_vector(7 downto 0);
      sevenseg_digit   : out std_logic_vector(digits-1 downto 0)
    );
  end component;

  type sevenseg_digits is array (integer range <>) of std_logic_vector(7 downto 0);

  component sevenseg_array is
    generic (
      digits : integer;
      clkdiv : integer := 12
    );
    port (
      clk : in std_logic;
      sevenseg_data    : in  sevenseg_digits(digits-1 downto 0);
      sevenseg_segment : out std_logic_vector(7 downto 0);
      sevenseg_digit   : out std_logic_vector(digits-1 downto 0)
    );
  end component;
end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sevenseg.all;

entity sevenseg_flat is
  generic (
    digits : integer;
    clkdiv : integer := 12
  );
  port (
    clk : in std_logic;
    sevenseg_data    : in  std_logic_vector(8*digits-1 downto 0);
    sevenseg_segment : out std_logic_vector(7 downto 0);
    sevenseg_digit   : out std_logic_vector(digits-1 downto 0)
  );
end entity sevenseg_flat;

architecture RTL of sevenseg_flat is
  signal data : sevenseg_digits(digits-1 downto 0);
begin
  map_data : process(sevenseg_data)
  begin
    for i in 0 to digits-1 loop
      data(i) <= sevenseg_data(8*i+7 downto 8*i);
    end loop;
  end process;
  
  inst: sevenseg_array
    generic map (digits => digits, clkdiv => clkdiv)
    port map (
      clk => clk,
      sevenseg_data => data,
      sevenseg_segment => sevenseg_segment,
      sevenseg_digit => sevenseg_digit
    );
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sevenseg.all;

entity sevenseg_array is
  generic (
    digits : integer;
    clkdiv : integer := 12
  );
  port (
    clk : in std_logic;
    sevenseg_data    : in  sevenseg_digits(digits-1 downto 0);
    sevenseg_segment : out std_logic_vector(7 downto 0);
    sevenseg_digit   : out std_logic_vector(digits-1 downto 0)
  );
end entity sevenseg_array;

architecture RTL of sevenseg_array is
  type tState is (fsmINIT, fsmSWITCH_TO, fsmDISPLAY, fsmSWITCH_FROM);
  signal state : tState := fsmINIT;
  signal cnt : unsigned(clkdiv downto 0);
  subtype tDIGIT_INDEX is integer range 0 to digits-1;
  signal digit_index : tDIGIT_INDEX := 0;
begin
  fsm: process(clk)
  begin
    if rising_edge(clk) then
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
          sevenseg_segment <= not(sevenseg_data(digit_index));
        when fsmSWITCH_FROM =>
          state <= fsmSWITCH_TO;
          if digit_index < digits-1 then
            digit_index <= digit_index + 1;
          else
            digit_index <= 0;
          end if;

          sevenseg_digit <= (others => '1');
          sevenseg_digit(digit_index) <= '0';
          sevenseg_segment <= (others => '1');
      end case;
    end if;
  end process;
end architecture;
