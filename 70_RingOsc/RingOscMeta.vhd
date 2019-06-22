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

  ring : entity work.ring2
    generic map (
      sel_input => 1,
      sel_sync  => 0
    )
    port map (
      clk_ring    => clk_ring,
      clk_ringosc => clk_ringosc,
      rst         => rst,
      pll_locked  => pll_locked,
      input       => input,
      leds        => leds
    );
end architecture;
