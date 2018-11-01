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
  signal cnt : std_logic_vector(35 downto 0) := (others => '0');
  signal sevenseg_data : std_logic_vector(63 downto 0) := (0 => '1', others => '0');
  signal uart_rx_valid, uart_rx_error : std_logic;
  signal uart_rx_data : std_logic_vector(7 downto 0);
  signal uart_tx_valid : std_logic := '0';
  signal uart_tx_ready : std_logic;
  signal uart_tx_data : std_logic_vector(7 downto 0);
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

  uart_inst: entity work.uart
    port map (clk, uart_rx, uart_tx,
      uart_rx_valid, uart_rx_error, uart_rx_data,
      uart_tx_valid, uart_tx_ready, uart_tx_data);

  sevenseg_display: sevenseg_flat
    generic map (digits => 8)
    port map (
      clk => clk,
      sevenseg_data => sevenseg_data,
      sevenseg_segment => sevenseg_segment,
      sevenseg_digit => sevenseg_digit
    );
  gen_sevenseg: process(clk)
    variable uart_index : integer := -1;
    variable button5_string_index : integer := 0;
  begin
    if rising_edge(clk) then
      if to_integer(unsigned(cnt(22 downto 0))) = 0 and uart_index = -1 then
        sevenseg_data <= sevenseg_data(sevenseg_data'left-1 downto 0) & sevenseg_data(sevenseg_data'left);
      end if;

      uart_tx_valid <= '0';

      if buttons(2)='0' then
        uart_tx_valid <= '1';
        uart_tx_data <= std_logic_vector(to_unsigned(48+2, 8));
      end if;

      if buttons(3)='0' then
        sevenseg_data <= x"ffffffffffffffff";
        uart_tx_valid <= '1';
        uart_tx_data <= std_logic_vector(to_unsigned(48+3, 8));
      end if;

      if buttons(4)='0' then
        sevenseg_data <= x"8040201008040201";
        uart_tx_valid <= '1';
        uart_tx_data <= std_logic_vector(to_unsigned(48+4, 8));
      end if;

      if buttons(5)='0' then
        uart_tx_valid <= '1';
        case button5_string_index is
          when  0 => uart_tx_data <= x"48";
          when  1 => uart_tx_data <= x"65";
          when  2 => uart_tx_data <= x"6c";
          when  3 => uart_tx_data <= x"6c";
          when  4 => uart_tx_data <= x"6f";
          when  5 => uart_tx_data <= x"20";
          when  6 => uart_tx_data <= x"57";
          when  7 => uart_tx_data <= x"6f";
          when  8 => uart_tx_data <= x"72";
          when  9 => uart_tx_data <= x"6c";
          when 10 => uart_tx_data <= x"64";
          when 11 => uart_tx_data <= x"21";
          when 12 => uart_tx_data <= x"0d";
          when 13 => uart_tx_data <= x"0a";
          when others => uart_tx_valid <= '0';
        end case;
        if uart_tx_valid='1' and uart_tx_ready='1' and button5_string_index < 14 then
          button5_string_index := button5_string_index + 1;
          uart_tx_valid <= '0';  -- uart_tx_data is old so reset valid
        end if;
      else
        button5_string_index := 0;
      end if;

      if uart_rx_valid='1' then
        uart_index := 0;
        sevenseg_data <= sevenseg_data(sevenseg_data'left-16 downto 0) & (7 downto 0 => uart_rx_error) & uart_rx_data;
      end if;
    end if;
  end process;
end architecture;
