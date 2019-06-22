library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ring is
  port (
    clk_ring   : in std_logic;
    rst        : in std_logic;
    pll_locked : in std_logic;
    input      : in std_logic;
    leds       : out std_logic_vector(3 to 14)
  );
end entity;

architecture RTL of ring is
  signal ring_state : std_logic_vector(leds'range);
  signal ring_cnt   : unsigned(19 downto 0);
begin
  ring : process(rst, pll_locked, clk_ring)
  begin
    if rst = '0' or pll_locked = '0' then
      ring_state <= (ring_state'left => '0', others => '1');
      ring_cnt   <= (others => '0');
    elsif rising_edge(clk_ring) then
      if input = '0' and to_integer(ring_cnt) = to_integer(unsigned(ring_state)) then
        ring_state <= ring_state(ring_state'left+1 to ring_state'right) & ring_state(ring_state'left);
      elsif input = '0' then
        ring_cnt <= ring_cnt + 1;
      else
        ring_cnt <= to_unsigned(to_integer(unsigned(ring_state)), ring_cnt'length);
      end if;
    end if;
  end process;

  leds <= ring_state;
end architecture;
