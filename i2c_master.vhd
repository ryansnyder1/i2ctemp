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
signal s_temp_data_reg : std_logic_vector(7 downto 0);

--200khz/10khz = 20 -> 20/2 (half the period) = 10 -> 4 bit representation
signal scount_10k : std_logic_vector(3 downto 0) := "0000";
signal sclk10 : std_logic := '1';

begin

----10khz SCL clock generator process----
process(clk_200khz, rst)
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

type tstates is (idle, start, addr_b6, addr_b5, addr_b4, addr_b3, addr_b2, 
addr_b1, addr_b0, rd_bit, rxack, msb_b7, msb_b6, msb_b5, msb_b4, msb_b3, msb_b2, msb_b1,
msb_b0, txack, lsb_b7, lsb_b6, lsb_b5, lsb_b4, lsb_b3, lsb_b2, lsb_b1, lsb_b0, txnack);
signal sstates : tstates;
signal s_HTL : std_logic_vector(11 downto 0) := (others => '0'); --counter for timing period between idle and wait and high to low transition for start condition on sda line.
signal sstatecnt : std_logic_vector(11 downto 0) := (others => '0');


----State Transitions----
process(clk_200khz, rst)
begin
    if rising_edge(clk_200khz) then
        if rst = '1' then
            sstates <= start;
            s_HTL <= X"7d0"; --10 ms period between idle and start state -> 2000 ticks
        else
        end if;
    end if;
end process;


end architecture behav;


