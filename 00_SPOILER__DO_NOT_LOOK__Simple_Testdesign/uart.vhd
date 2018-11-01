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
    rx_data  : out std_logic_vector(7 downto 0);
    tx_valid : in  std_logic;
    tx_ready : out std_logic;
    tx_data  : in  std_logic_vector(7 downto 0)
  );
end entity;

architecture RTL of uart is
  constant clkdiv : integer := 50*1000*1000 / 115200;
  type tSTATE is (fsmWAIT_IDLE, fsmWAIT_START, fsmBYTE);
  signal state : tSTATE := fsmWAIT_IDLE;
  signal clkcnt : unsigned(integer(ceil(log2(real(clkdiv)))) downto 0) := (others => '0');
  signal bitcnt : unsigned(3 downto 0) := (others => '0');
  signal rxshift : std_logic_vector(9 downto 0) := (others => '0');
  signal rxs1, rxs2, rxs : std_logic;

  type tTXSTATE is (fsmWAIT_DATA, fsmSTARTBIT, fsmTXDATA, fsmSTOPBIT);
  signal txstate : tTXSTATE := fsmWAIT_DATA;
  signal tx_shift : std_logic_vector(7 downto 0);
  signal txclkcnt : unsigned(integer(ceil(log2(real(clkdiv)))) downto 0) := (others => '0');
  signal txbitcnt : unsigned(2 downto 0) := (others => '0');
  signal tx_ready_int : std_logic := '0';
begin
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
            rxshift <= rxs & rxshift(rxshift'left downto 1);
            if to_integer(bitcnt)+1 = 1+8+2 then
              rx_valid <= '1';
              rx_error <= rxshift(1) or not(rxs);
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
  
  rx_data <= rxshift(8 downto 1);
 
  transmit : process(clk)
  begin
    if rising_edge(clk) then
      case txstate is
        when fsmWAIT_DATA =>
          tx_ready_int <= '1';
          tx <= '1';
          if tx_valid='1' then
            tx_shift <= tx_data;
            txstate <= fsmSTARTBIT;
            if tx_ready_int='1' then
              tx_ready_int <= '0';
            end if;
            txclkcnt <= to_unsigned(2**clkcnt'left - (clkdiv-1), clkcnt'length);
          end if;
        when fsmSTARTBIT =>
          tx_ready_int <= '0';
          tx <= '0';
          txbitcnt <= (others => '1');
          if txclkcnt(txclkcnt'left)='1' then
            txclkcnt <= to_unsigned(2**clkcnt'left - (clkdiv-1), clkcnt'length);
            txstate <= fsmTXDATA;
          else
            txclkcnt <= txclkcnt + 1;
          end if;
        when fsmTXDATA =>
          tx_ready_int <= '0';
          tx <= tx_shift(0);
          if txclkcnt(txclkcnt'left)='1' then
            txclkcnt <= to_unsigned(2**clkcnt'left - (clkdiv-1), clkcnt'length);
            txbitcnt <= txbitcnt - 1;
            tx_shift <= '0' & tx_shift(7 downto 1);
            if txbitcnt = 0 then
              txstate <= fsmSTOPBIT;
              tx_ready_int <= '1';
            end if;
          else
            txclkcnt <= txclkcnt + 1;
          end if;
        when fsmSTOPBIT =>
          tx <= '1';
          if tx_ready_int='1' and tx_valid='1' then
            tx_ready_int <= '0';
            tx_shift <= tx_data;
          end if;
          if txclkcnt(txclkcnt'left)='1' then
            if tx_valid='1' or tx_ready_int='0' then
              txstate <= fsmSTARTBIT;
              txclkcnt <= to_unsigned(2**clkcnt'left - (clkdiv-1), clkcnt'length);
            else
              txstate <= fsmWAIT_DATA;
            end if;
          else
            txclkcnt <= txclkcnt + 1;
          end if;
      end case;
    end if;
  end process;

  tx_ready <= tx_ready_int;
end architecture;
