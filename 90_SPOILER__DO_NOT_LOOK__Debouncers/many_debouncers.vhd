library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sevenseg.all;

entity many_debouncers is
  generic (
    debounce_time : time := 10 ms;
    clk_period    : time := 20 ns
  );
  port (
    clk, rst : in std_logic;
    input    : in std_logic;
    dipswitch : in std_logic_vector(1 to 8);
    leds             : out std_logic_vector(3 to 14);
    sevenseg_segment : out std_logic_vector(7 downto 0);
    sevenseg_digit   : out std_logic_vector(7 downto 0)
  );
end entity;

architecture RTL of many_debouncers is
  constant digits : integer := 8;
  signal sevenseg_data : sevenseg_digits(digits-1 downto 0);
  type tBCD_DIGITS is array(integer range <>) of unsigned(3 downto 0);
  signal bcd_counter : tBCD_DIGITS(digits-1 downto 0);
  signal previous : std_logic := '1';
  
  function "+"(bcd : tBCD_DIGITS; inc : integer) return tBCD_DIGITS is
    variable result : tBCD_DIGITS(bcd'range) := bcd;
    variable inc2 : integer := inc;
    variable tmp, tmp2 : unsigned(5 downto 0);
  begin
    for i in bcd'low to bcd'high loop
      if inc2 = 0 then
        exit;
      else
        tmp := result(i) + unsigned'("000000") + (inc2 mod 10);
        tmp2 := tmp mod 10;
        result(i) := tmp2(3 downto 0);
        inc2 := inc2 / 10 + to_integer(tmp) / 10;
      end if;
    end loop;
    return result;
  end function;

  component pll is
      port (
          clk_clk          : in  std_logic := 'X'; -- clk
          clk_cnt_clk      : out std_logic;        -- clk
          clk_debounce_clk : out std_logic;        -- clk
          clk_ring_clk     : out std_logic;        -- clk
          reset_reset_n    : in  std_logic := 'X'; -- reset_n
          locked_export    : out std_logic         -- export
      );
  end component pll;

  signal clk_cnt, clk_debounce, clk_ring, pll_locked : std_logic;
  signal ring_state : std_logic_vector(leds'range);
  signal ring_cnt   : unsigned(19 downto 0);
  signal ring_input : std_logic;
begin
  u0 : pll
      port map (
          clk_clk          => clk,
          clk_cnt_clk      => clk_cnt,
          clk_debounce_clk => clk_debounce,
          clk_ring_clk     => clk_ring,
          reset_reset_n    => '1',
          locked_export    => pll_locked
      );

  sevenseg_display: sevenseg_array
    generic map (digits => digits)
    port map (
      clk => clk_cnt,
      sevenseg_data    => sevenseg_data,
      sevenseg_segment => sevenseg_segment,
      sevenseg_digit   => sevenseg_digit
    );

  count : process (rst, clk_cnt)
  begin
    if rst = '0' then
      previous <= '1';
      bcd_counter <= (0 => "0010", 1 => "0100", others => (others => '0'));
    elsif rising_edge(clk_cnt) then
      previous <= input;
      if previous /= input then
        bcd_counter(3 downto 0) <= bcd_counter(3 downto 0) + 1;
        bcd_counter(7 downto 4) <= bcd_counter(7 downto 4) + 1;
      end if;
    end if;
  end process;
  
  bcd_to_digits : process (bcd_counter)
    constant to_digit : sevenseg_digits(0 to 15) := (
      0 => x"3f",
      1 => x"06",
      2 => x"5b",
      3 => x"4f",
      4 => x"66",
      5 => x"6d",
      6 => x"7d",
      7 => x"07",
      8 => x"7f",
      9 => x"6f",
      others => x"80"
    );
  begin
    for i in bcd_counter'range loop
      sevenseg_data(i) <= to_digit(to_integer(bcd_counter(i)));
    end loop;
  end process;

  debouncers : for i in leds'range generate
    signal x, y, z : std_logic;
  begin
    y <= input xor dipswitch(i mod 8 + 1) xor dipswitch(i/8 mod 8 + 1);

    d : entity work.debounce
      generic map (debounce_time => debounce_time, clk_period => clk_period)
      port map (clk => clk_debounce, rst => rst, input => y, output => x);
    
    t : entity work.toggle
      generic map (active_state => '0')
      port map (clk => clk_debounce, rst => rst, input => x, output => z);

    --leds(i) <= z;
  end generate;

  ring : process(rst, pll_locked, clk_ring)
  begin
    if rst = '0' or pll_locked = '0' then
      ring_state <= (ring_state'left => '0', others => '1');
      ring_cnt   <= (others => '0');
    elsif rising_edge(clk_ring) then
      ring_input <= input;
      if input = '0' then
        ring_cnt <= ring_cnt + 1;
      end if;
      if input = '0' and ring_cnt = 4242 then
        ring_state <= ring_state(ring_state'left+1 to ring_state'right) & ring_state(ring_state'left);
      end if;
    end if;
  end process;
  leds <= ring_state;
end architecture;
