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
    variable led1 : integer := 6;
    variable led2 : integer := 5;
    variable led3 : integer := 4;
    variable led4 : integer := 3;
  begin
    if rising_edge(clk) then
      if to_integer(unsigned(cnt(22 downto 0))) = 0 and buttons(3)='1' then
        if led1 < leds'high then
          led1 := led1 + 1;
        else
          led1 := leds'low;
        end if;
        if led1 > leds'low then
          led2 := led1 - 1;
        else
          led2 := leds'high;
        end if;
        if led2 > leds'low then
          led3 := led2 - 1;
        else
          led3 := leds'high;
        end if;
        if led3 > leds'low then
          led4 := led3 - 1;
        else
          led4 := leds'high;
        end if;
      end if;
      
      leds <= (others => '1');
      leds(led1) <= '0';
      leds(led2) <= cnt(15);
      leds(led3) <= cnt(15) or cnt(14);
      leds(led4) <= cnt(16) or cnt(15) or cnt(14) or cnt(13);
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
