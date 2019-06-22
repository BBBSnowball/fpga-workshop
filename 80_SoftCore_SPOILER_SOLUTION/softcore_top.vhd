library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sevenseg.all;

entity softcore_top is
  port (
    clk : in std_logic;
    buttons : in std_logic_vector(2 to 5);
    switches : in std_logic_vector(1 to 8);
    sevenseg_segment : out std_logic_vector(7 downto 0);
    sevenseg_digit   : out std_logic_vector(7 downto 0)
  );
end entity softcore_top;

architecture RTL of softcore_top is
  signal cnt : std_logic_vector(35 downto 0) := (others => '0');
  signal sevenseg_data : std_logic_vector(63 downto 0) := (0 => '1', others => '0');

    component softcore is
        port (
            clk_clk       : in  std_logic                     := 'X'; -- clk
            reset_reset_n : in  std_logic                     := 'X'; -- reset_n
            pio0_export   : out std_logic_vector(31 downto 0);        -- export
            pio1_export   : out std_logic_vector(31 downto 0);        -- export
            pio2_export   : in  std_logic_vector(11 downto 0) := (others => 'X')  -- export
        );
    end component softcore;
begin
  p : process(clk)
  begin
    if rising_edge(clk) then
      cnt <= std_logic_vector(unsigned(cnt)+1);
    end if;
  end process;

  sevenseg_display: sevenseg_flat
    generic map (digits => 8)
    port map (
      clk => clk,
      sevenseg_data => sevenseg_data,
      sevenseg_segment => sevenseg_segment,
      sevenseg_digit => sevenseg_digit
    );
 
  qsys_system : component softcore
    port map (
      clk_clk       => clk,
      reset_reset_n => '1',
      pio0_export   => sevenseg_data(31 downto 0),
      pio1_export   => sevenseg_data(63 downto 32),
      pio2_export   => buttons & switches
    );
end architecture;
