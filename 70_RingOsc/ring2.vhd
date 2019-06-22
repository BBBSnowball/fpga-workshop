library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ring2 is
  generic (
    sel_input : integer;
    sel_sync  : integer
  );
  port (
    clk_ring    : in std_logic;
    clk_ringosc : in std_logic;
    rst         : in std_logic;
    pll_locked  : in std_logic;
    input       : in std_logic;
    leds        : out std_logic_vector(3 to 14)
  );
end entity;

architecture RTL of ring2 is
  signal ring_input, ring_input2 : std_logic;
  signal ring_sync1, ring_sync2 : std_logic;
begin
  ring_input <= input                when sel_input = 0 else
                input or clk_ringosc;

  ring_input2 <= ring_input          when sel_sync = 0 else
                 ring_sync1          when sel_sync = 1 else
                 ring_sync2;
  
  sync : process(rst, pll_locked, clk_ring)
  begin
    if rst = '0' or pll_locked = '0' then
      ring_sync1 <= '0';
      ring_sync2 <= '0';
    elsif rising_edge(clk_ring) then
      ring_sync1 <= ring_input;
      ring_sync2 <= ring_sync1;
    end if;
  end process;

  ring : entity work.ring
    port map (
      clk_ring   => clk_ring,
      rst        => rst,
      pll_locked => pll_locked,
      input      => ring_input2,
      leds       => leds
    );
end architecture;
