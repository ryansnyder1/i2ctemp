library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_master is 
        port(
            clk_200khz : in std_logic;
            rst : in std_logic;
            sda : inout std_logic;
            tmp : out std_logic_vector(7 downto 0);
            sda_dir : out std_logic;
            scl : out std_logic
        );
end i2c_master;

architecture behav of i2c_master is

--signal declarations--
signal s_addrrd : std_logic_vector(7 downto 0) := "10010111"; --Temp sensor address (0x4b) + read bit (1) = 0x97
signal sMSB : std_logic_vector(7 downto 0) := "00000000";
signal sLSB : std_logic_vector(7 downto 0) := "00000000";
signal s_init_sda : std_logic := '1';  --initial sda bit set to high
signal s_temp_data_reg : std_logic_vector;

--200khz/10khz = 20 -> 20/2 (half the period) = 10 -> 4 bit representation
signal scount_10k : std_logic_vector(3 downto 0) := "0000";
signal sclk10 : std_logic := '1';

begin

----10khz SCL clock generator process----
process(clk_200khz)
begin
    if rising_edge(clk_200khz) then
        if rst = '1' then
            scount_10k <= "0000";
            sclk10 <= '0';
        else
            if scount_10k = "1001" then
                scount_10k <= "0000";
                sclk10 <= not sclk10;
            else
                scount_10k <= std_logic_vector(unsigned(scount_10k) + 1);
            end if; 
        end if;
    end if;
end process;

scl <= sclk10;
-----------------------------------------



end architecture behav;


