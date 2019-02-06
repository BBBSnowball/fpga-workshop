library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity debounce is
  generic (
    debounce_time : time := 10 ms;
    clk_period    : time := 20 ns
  );
  port (
    clk    : in std_logic;
    rst    : in std_logic;
    input  : in std_logic;
    output : out std_logic
  );
end entity;

library ieee;
use ieee.std_logic_1164.all;

entity toggle is
  generic (
    initial_state : std_logic := '0';
    active_state  : std_logic := '1'
  );
  port (
    clk    : in std_logic;
    rst    : in std_logic;
    input  : in std_logic;
    output : out std_logic
  );
end entity;

architecture RTL of toggle is
  signal state : std_logic := initial_state;
  signal previous : std_logic := '0';
begin
  p : process(rst, clk)
  begin
    if rst = '0' then
      state <= initial_state;
      previous <= '0';
    elsif rising_edge(clk) then
      previous <= input;
      if previous /= input and input = active_state then
        state <= not(state);
      end if;
    end if;
  end process;
  
  output <= state;
end architecture;

architecture RTL of debounce is
  constant debounce_cycles : integer := debounce_time / clk_period;
  constant debounce_bits : integer := integer(ceil(log2(real(debounce_cycles+1))));

  signal counter : unsigned(debounce_bits downto 0) := (others => '1');
  signal state : std_logic := '0';
begin
  p : process(rst, clk)
  begin
    if rst = '0' then
      counter <= (others => '1');
      state <= '0';
    elsif rising_edge(clk) then
      if counter(counter'left) = '1' then
        state <= input;
        counter <= to_unsigned(2**debounce_bits - debounce_cycles, debounce_bits+1);
      elsif state = input then
        counter <= to_unsigned(2**debounce_bits - debounce_cycles, debounce_bits+1);
      else
        counter <= counter + 1;
      end if;
    end if;
  end process;
  
  output <= state;
end architecture;
