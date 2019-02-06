library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_port_rom is
  generic 
  (
    DATA_WIDTH : natural := 8;
    ADDR_WIDTH : natural := 15
  );
  port 
  (
    clk   : in std_logic;
    addr  : in natural range 0 to 2**ADDR_WIDTH - 1;
    q   : out std_logic_vector((DATA_WIDTH -1) downto 0)
  );

end entity;

use work.pcmdata.all;

architecture rtl of single_port_rom is

  -- Build a 2-D array type for the RoM
  subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
  type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;

  function init_rom
    return memory_t is 
    variable tmp : memory_t := (others => (others => '0'));
  begin 
    for addr_pos in 0 to 2**ADDR_WIDTH - 1 loop
      if addr_pos < pcmsamples'length then
        tmp(addr_pos) := std_logic_vector(abs(pcmsamples(addr_pos)));
      else
        tmp(addr_pos) := (others => '0');
      end if;
    end loop;
    return tmp;
  end init_rom;  

  -- Declare the ROM signal and specify a default value.  Quartus II
  -- will create a memory initialization file (.mif) based on the 
  -- default value.
  signal rom : memory_t := init_rom;

begin

  process(clk)
  begin
  if(rising_edge(clk)) then
    q <= rom(addr);
  end if;
  end process;

end rtl;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pcmdata.all;

entity buzzerpcm is
   port (
      clk  : IN std_logic;
      rst  : IN std_logic;   
      out_bit  : OUT std_logic);   
END entity;

architecture RTL of buzzerpcm is
  --type tSAMPLES is array(integer range <>) of std_logic_vector(7 downto 0);
  --impure function read_wav(path : string) return tSAMPLES is
  --  type t_byte_file is file of character;
  --  file f : t_byte_file open read_mode is "./nootnoot01a.wav"; --path;
  --  variable ch : character;
  --  variable samples : tSAMPLES(1023 downto 0) := (others => (others => '0'));
  --begin
  --  for i in 0 to 15 loop
  --    -- Quartus doesn't support this, it seems. Too bad.
  --    -- https://stackoverflow.com/questions/29298179/vhdl-file-system-operations-synthesis
  --    read(f, ch);
  --    report integer'image(i) & ": " & integer'image(character'pos(ch));
  --  end loop;
  --  return samples;
  --end function;
  --constant samples : tSAMPLES(1023 downto 0) := read_wav("./nootnoot01a.wav");

  -- 50Mhz / 256 / 4 is roughly 44.1 khz so we are going to use that.
  constant pwm_cycles_per_sample : integer := 4;
  signal cycle_cnt : integer := 0;
  signal pwm_cnt : unsigned(7 downto 0) := (others => '0');
  signal sample_cnt : integer range 0 to 16383 := 0;
  signal done : std_logic := '0';
  --signal current_sample : signed(7 downto 0);
  signal current_sample : std_logic_vector(7 downto 0);

  --type tSAMPLES_ROM is array(integer range <>) of std_logic_vector(7 downto 0);
  signal samples_rom : tSAMPLES(0 to 16383) := pcmsamples(0 to 16383);
begin
  pcmgen : process(rst, clk)
  begin
    if rst = '0' then
      out_bit <= '1';
      cycle_cnt <= 0;
      pwm_cnt <= (others => '0');
      sample_cnt <= 0;
      done <= '0';
    elsif rising_edge(clk) then
      if done = '1' then
        out_bit <= '1';
      else
        pwm_cnt <= pwm_cnt + 1;
        if pwm_cnt < unsigned(current_sample) then
          out_bit <= '0';
        else
          out_bit <= '1';
        end if;
        if pwm_cnt = x"ff" then
          if cycle_cnt = pwm_cycles_per_sample-1 then
            cycle_cnt <= 0;
            if sample_cnt = 16384-1 then
              done <= '1';
            else
              sample_cnt <= sample_cnt + 1;
            end if;
          else
            cycle_cnt <= cycle_cnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process;
  
  --current_sample <= abs(samples_rom(sample_cnt));
  rom : entity work.single_port_rom port map (clk => clk, addr => sample_cnt, q => current_sample);

end architecture;