library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity uart is
  port (
    clk : in  std_logic;
    rx  : in  std_logic;
    tx  : out std_logic;
    rx_valid : out std_logic;
    rx_error : out std_logic;
    rx_data  : out std_logic_vector(7 downto 0)
  );
end entity;

architecture RTL of uart is
  constant clkdiv : integer := 50*1000*1000 / 115200;
  type tSTATE is (fsmWAIT_IDLE, fsmWAIT_START, fsmBYTE);
  signal state : tSTATE := fsmWAIT_IDLE;
  signal clkcnt : unsigned(integer(ceil(log2(real(clkdiv)))) downto 0) := (others => '0');
  signal bitcnt : unsigned(3 downto 0) := (others => '0');
  signal rxdata : std_logic_vector(10 downto 0) := (others => '0');
  signal rxs1, rxs2, rxs : std_logic;
begin
  tx <= 'Z';
  
  receive: process(clk)
  begin
    if rising_edge(clk) then
      rx_valid <= '0';
      rx_error <= '0';
      rxs1 <= rx;
      rxs2 <= rxs1;
      rxs <= rxs2;
      case state is
        when fsmWAIT_IDLE =>
          if rxs='0' then
            clkcnt <= to_unsigned(2**clkcnt'left - (clkdiv-1), clkcnt'length);
            bitcnt <= (others => '0');
          else
            clkcnt <= clkcnt + 1;
            if clkcnt(clkcnt'left)='1' then
              bitcnt <= bitcnt + 1;
              if bitcnt = "1111" then
                state <= fsmWAIT_START;
              end if;
            end if;
          end if;
        when fsmWAIT_START =>
          if rxs='0' then
            clkcnt <= to_unsigned(2**clkcnt'left - (clkdiv/2-1), clkcnt'length);
            bitcnt <= (others => '0');
            state <= fsmBYTE;
          end if;
        when fsmBYTE =>
          clkcnt <= clkcnt + 1;
          if clkcnt(clkcnt'left)='1' then
            clkcnt <= to_unsigned(2**clkcnt'left - (clkdiv-1), clkcnt'length);
            bitcnt <= bitcnt + 1;
            rxdata <= rxs & rxdata(rxdata'left downto 1);
            if to_integer(bitcnt)+1 = 1+8+2 then
              rx_valid <= '1';
              --rx_error <= rxdata(0) or not(rxdata(9)) or not(rxdata(10));
              rx_error <= rxdata(1) or not(rxdata(10)) or not(rxs);
              if rxs='1' then
                state <= fsmWAIT_START;
              else
                -- stop bit is not '1'
                state <= fsmWAIT_IDLE;
              end if;
            end if;
          end if;
      end case;
    end if;
  end process;
  
  rx_data <= rxdata(8 downto 1);
end architecture;
