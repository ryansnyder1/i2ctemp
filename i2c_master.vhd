library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity i2c_master is 
        port(
            clk_200khz : in std_logic;
            rst : in std_logic;
            sda : inout std_logic;
            tmp : out std_logic_vector(7 downto 0);
            sda_dir : inout std_logic;
            scl : out std_logic
        );
end i2c_master;

architecture behav of i2c_master is

--signal declarations--
signal s_addrrd : std_logic_vector(7 downto 0) := "10010111"; --Temp sensor address (0x4b) + read bit (1) = 0x97
signal sMSB : std_logic_vector(7 downto 0) := "00000000";
signal sLSB : std_logic_vector(7 downto 0) := "00000000";
signal sda_out : std_logic := '1';  --initial sda bit set to high
signal sda_in : std_logic;
signal s_temp_data_reg : std_logic_vector(7 downto 0);

--200khz/10khz = 20 -> 20/2 (half the period) = 10 -> 4 bit representation
signal scount_10k : std_logic_vector(3 downto 0) := "0000";
signal sclk10 : std_logic := '1';

type tstates is (idle, start, addr_b6, addr_b5, addr_b4, addr_b3, addr_b2, addr_b1, addr_b0, rd_bit, rxack, msb_b7, msb_b6, msb_b5, msb_b4, msb_b3, msb_b2, msb_b1, msb_b0, txack, lsb_b7, lsb_b6, lsb_b5, lsb_b4, lsb_b3, lsb_b2, lsb_b1, lsb_b0, txnack);
signal sstates : tstates;
signal s_HTL : std_logic_vector(11 downto 0) := (others => '0'); --counter for timing period between idle and wait and high to low transition for start condition on sda line.
signal sstatecnt : std_logic_vector(11 downto 0) := (others => '0');

signal ssda_dir : std_logic;

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




----State Transitions----
process(clk_200khz, rst)
begin
    if rising_edge(clk_200khz) then
        if rst = '1' then
            sstates <= start;
            s_HTL <= X"7d0"; --10 ms period between idle and start state -> 2000 ticks
        else
            s_HTL <= s_HTL + 1;
            case sstates is
               when idle => if s_HTL = X"7cf" then sstates <= start; end if;
               when start => if s_HTL = X"7dd" then sstates <= addr_b6; end if;  --at 2004 ticks (0x7d4) set sda_out HIGH (Output process block)
               when addr_b6 => if sstatecnt = X"14" then sstates <= addr_b5; end if;
               when addr_b5 => if sstatecnt = X"14" then sstates <= addr_b4; end if;
               when addr_b4 => if sstatecnt = X"14" then sstates <= addr_b3; end if;
               when addr_b3 => if sstatecnt = X"14" then sstates <= addr_b2; end if;
               when addr_b2 => if sstatecnt = X"14" then sstates <= addr_b1; end if;
               when addr_b1 => if sstatecnt = X"14" then sstates <= addr_b0; end if;
               when addr_b0 => if sstatecnt = X"14" then sstates <= rd_bit; end if;
               when rd_bit => if sstatecnt = X"14" then sstates <= rxack; end if;
               when rxack => if sstatecnt = X"14" then sstates <= msb_b7; end if;
               when msb_b7 => if sstatecnt = X"14" then sstates <= msb_b6; end if;
               when msb_b6 => if sstatecnt = X"14" then sstates <= msb_b5; end if;
               when msb_b5 => if sstatecnt = X"14" then sstates <= msb_b4; end if;
               when msb_b4 => if sstatecnt = X"14" then sstates <= msb_b3; end if;
               when msb_b3 => if sstatecnt = X"14" then sstates <= msb_b2; end if;
               when msb_b2 => if sstatecnt = X"14" then sstates <= msb_b1; end if;
               when msb_b1 => if sstatecnt = X"14" then sstates <= msb_b0; end if;
               when msb_b0 => if sstatecnt = X"14" then sstates <= txack; end if;

               when txack => if sstatecnt = X"14" then sstates <= lsb_b7; end if;
               when lsb_b7 => if sstatecnt = X"14" then sstates <= lsb_b6; end if;
               when lsb_b6 => if sstatecnt = X"14" then sstates <= lsb_b5; end if;
               when lsb_b5 => if sstatecnt = X"14" then sstates <= lsb_b4; end if;
               when lsb_b4 => if sstatecnt = X"14" then sstates <= lsb_b3; end if;
               when lsb_b3 => if sstatecnt = X"14" then sstates <= lsb_b2; end if;
               when lsb_b2 => if sstatecnt = X"14" then sstates <= lsb_b1; end if;
               when lsb_b1 => if sstatecnt = X"14" then sstates <= lsb_b0; end if;
               when lsb_b0 => if sstatecnt = X"14" then sstates <= txnack; end if;
               when txnack => if sstatecnt = X"14" then s_HTL <= X"7d0"; sstates <= start; end if;
            end case;
        end if;
        
    end if;
end process;

----Counter Process---
process(clk_200khz, rst)
begin 
  if rising_edge(clk_200khz) then
    if rst = '1' then 
        sstatecnt <= X"00";
    else
        case sstates is
            when idle|start => sstatecnt <= (others => '0');
            when others => sstatecnt <= sstatecnt + '1';
        end case;
    end if;
  end if;
end process;

sda_in <= sda;

----State I/O----
process(sstates)
begin
    case sstates is
        when start => if s_HTL = X"7d4" then sda_out <= '1'; end if;
        when addr_b6 => sda_out <= s_addrrd(7);
        when addr_b5 => sda_out <= s_addrrd(6);
        when addr_b4 => sda_out <= s_addrrd(5);
        when addr_b3 => sda_out <= s_addrrd(4);
        when addr_b2 => sda_out <= s_addrrd(3);
        when addr_b1 => sda_out <= s_addrrd(2);
        when addr_b0 => sda_out <= s_addrrd(1);
        when rd_bit => sda_out <= s_addrrd(0);
        --------------------------------------
        when msb_b7 => sMSB(7) <= sda_in;
        when msb_b6 => sMSB(6) <= sda_in;
        when msb_b5 => sMSB(5) <= sda_in;
        when msb_b4 => sMSB(4) <= sda_in;
        when msb_b3 => sMSB(3) <= sda_in;
        when msb_b2 => sMSB(2) <= sda_in;
        when msb_b1 => sMSB(1) <= sda_in;
        when msb_b0 => sMSB(0) <= sda_in;
        when lsb_b7 => sLSB(7) <= sda_in;
        when lsb_b6 => sLSB(6) <= sda_in;
        when lsb_b5 => sLSB(5) <= sda_in;
        when lsb_b4 => sLSB(4) <= sda_in;
        when lsb_b3 => sLSB(3) <= sda_in;
        when lsb_b2 => sLSB(2) <= sda_in;
        when lsb_b1 => sLSB(1) <= sda_in;
        when lsb_b0 => sLSB(0) <= sda_in; sda_out <= '1'; -- ???
        when txnack => s_temp_data_reg <= sMSB(6 downto 0) & sLSB(7);  -- send converted result
        ----------------------------------
        when others => null;
    end case;
end process;

--process(clk_200khz, sstates)
--begin
--    if rising_edge(clk_200khz) then
--        if sstates = txnack then 
--            s_temp_data_reg <= sMSB(6 downto 0) & sLSB(7);  -- send converted result
--        end if;
--    end if;
--end process;

----Setting SDA direction signal----
process(sstates)
begin
    if(sstates = idle or sstates = start or sstates = addr_b6 or sstates = addr_b5 or sstates = addr_b4 or sstates = addr_b3 or sstates = addr_b2 or sstates = addr_b1 or sstates = addr_b0 or sstates = rd_bit or sstates = txack or sstates = txnack) then --in states where master is sending data -> set sda direction to 1 for outputting
        sda_dir <= '1';
    else
        sda_dir <= '0'; --in other states set sda direction to 0 to act as an input for master to receive data from slave
    end if;
end process;

----SDA Direction for Output----
process(sda_dir, sda_out)
begin
    if sda_dir = '1' then 
        sda <= sda_out; --allow master to send
    else
        sda <= 'Z'; --allow master to receive -> set to high impedence state
    end if;
end process;

sda_in <= sda;


end architecture behav;


