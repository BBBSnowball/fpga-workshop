library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RingOscMeta is
  port (
    clk, rst : in std_logic;
    input    : in std_logic;
    leds     : out std_logic_vector(3 to 14)
  );
end entity;

architecture RTL of RingOscMeta is
  component pll is
      port (
          clk_clk          : in  std_logic := 'X'; -- clk
          clk_ring_clk     : out std_logic;        -- clk
          reset_reset_n    : in  std_logic := 'X'; -- reset_n
          locked_export    : out std_logic         -- export
      );
  end component pll;

  signal clk_ring, pll_locked : std_logic;
  signal clk_ringosc : std_logic;
  signal ring_state : std_logic_vector(leds'range);
  signal ring_cnt   : unsigned(19 downto 0);
  signal ring_input : std_logic;
  signal ring_input2, ring_sync1, ring_sync2 : std_logic;
begin
  u0 : pll
      port map (
          clk_clk          => clk,
          clk_ring_clk     => clk_ring,
          reset_reset_n    => '1',
          locked_export    => pll_locked
      );
  
  ringosc_inst : entity work.ringosc
    port map (clk => clk_ringosc);

  ring : process(rst, pll_locked, clk_ring)
  begin
    if rst = '0' or pll_locked = '0' then
      ring_state <= (ring_state'left => '0', others => '1');
      ring_cnt   <= (others => '0');
      ring_sync1 <= '0';
      ring_sync2 <= '0';
    elsif rising_edge(clk_ring) then
      if ring_input2 = '0' and to_integer(ring_cnt) = to_integer(unsigned(ring_state)) then
        ring_state <= ring_state(ring_state'left+1 to ring_state'right) & ring_state(ring_state'left);
      elsif ring_input2 = '0' then
        ring_cnt <= ring_cnt + 1;
      else
        ring_cnt <= to_unsigned(to_integer(unsigned(ring_state)), ring_cnt'length);
      end if;
      
      ring_sync1 <= ring_input;
      ring_sync2 <= ring_sync1;
    end if;
  end process;
  leds <= ring_state;

  --ring_input <= input;
  ring_input <= input or clk_ringosc;
  ring_input2 <= ring_input;
  --ring_input2 <= ring_sync1;
  --ring_input2 <= ring_sync2;
end architecture;
