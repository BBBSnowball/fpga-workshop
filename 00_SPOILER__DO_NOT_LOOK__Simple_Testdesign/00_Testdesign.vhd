library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sevenseg.all;

entity testdesign is
  port (
    clk : in std_logic;
    buttons : in std_logic_vector(2 to 5);
    switches : in std_logic_vector(1 to 8);
    leds : out std_logic_vector(3 to 14);
    bell : out std_logic;
    uart_rx : in std_logic;
    uart_tx : out std_logic;
    sevenseg_segment : out std_logic_vector(7 downto 0);
    sevenseg_digit   : out std_logic_vector(7 downto 0)
  );
end entity testdesign;

architecture RTL of testdesign is
  signal cnt : std_logic_vector(35 downto 0);
  signal sevenseg_data : std_logic_vector(63 downto 0) := (0 => '1', others => '0');
begin
  p : process(clk)
  begin
    if rising_edge(clk) then
      cnt <= std_logic_vector(unsigned(cnt)+1);
    end if;
  end process;

  gen_leds: process(clk)
    type intarray is array (integer range <>) of integer;
    --constant ledmapping : intarray(15 downto 0) := (6, 7, 8, -1, 9, 10, 11, -1, 12, 13, 14, -1, 3, 4, 5, -1);
    --constant ledmapping : intarray(15 downto 0) := (8, 7, 6, -1, 5, 4, 3, -1, 14, 13, 12, -1, 11, 10, 9, -1);
    constant ledmapping : intarray(11 downto 0) := (8, 7, 6, 5, 4, 3, 14, 13, 12, 11, 10, 9);
    variable ledstates : intarray(ledmapping'range) := (1, 1, 2, 3, 4, 5, others => 0);
  begin
    if rising_edge(clk) then
      if to_integer(unsigned(cnt(21 downto 0))) = 0 and buttons(3)='1' then
        ledstates := ledstates(ledstates'left-1 downto 0) & ledstates(ledstates'left);
      end if;

      leds <= (others => '1');
      for i in ledmapping'range loop
        if ledmapping(i) >= 0 then
          case ledstates(i) is
            when 1 => leds(ledmapping(i)) <= '0';
            when 2 => leds(ledmapping(i)) <= cnt(15);
            when 3 => leds(ledmapping(i)) <= cnt(15) or cnt(14);
            when 4 => leds(ledmapping(i)) <= cnt(16) or cnt(15) or cnt(14) or cnt(13);
            when 5 => leds(ledmapping(i)) <= cnt(17) or cnt(16) or cnt(15) or cnt(14) or cnt(13) or cnt(12);
            when others => leds(ledmapping(i)) <= '1';
          end case;
        end if;
      end loop;
    end if;
  end process;

  bell <= 'Z' when buttons(2) = '1'
    else cnt(25); -- button(2) is '0' if button is pressed

  uart_tx <= 'Z';

  --sevenseg_segment <= (0 => '0', 1 => '0', others => 'Z');
  --sevenseg_digit   <= (0 => '0', others => 'Z');

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
