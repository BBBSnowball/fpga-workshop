library ieee;
use ieee.std_logic_1164.all;

entity testbench is
end entity;

architecture RTL of testbench is
  signal clk : std_logic := '0';
  signal uart_rx : std_logic := '1';
begin
  DUT : entity work.testdesign
    port map (
      clk => clk,
      buttons => (others => '1'),
      switches => (others => '1'),
      uart_rx => uart_rx
    );

  clkgen : process
  begin
    wait for 10 ns;
    clk <= not(clk);
  end process;
  
  test_uart : process
    constant baud : time := 1 sec / 115200;
    procedure send_byte(data : std_logic_vector(7 downto 0)) is
    begin
      uart_rx <= '0';
      wait for baud;
      for i in 0 to 7 loop
        uart_rx <= data(i);
        wait for baud;
      end loop;
      uart_rx <= '1';
      wait for 2*baud;
    end procedure;
  begin
    uart_rx <= '1';
    wait for 150 us;
    uart_rx <= '0';
    wait for baud*9;
    uart_rx <= '1';
    wait for baud*2;
    wait for baud*3;
    send_byte(x"12");
    send_byte(x"34");
    send_byte(x"56");
    wait for baud;
    send_byte(x"78");
    wait;
  end process;
end architecture;
