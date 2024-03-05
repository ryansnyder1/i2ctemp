library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clkgen200 is 
port(
    clk_100mhz : in std_logic;
    clk_200khz : out std_logic 
    );
end clkgen200;

architecture behav of clkgen200 is

--100Mhz/200khz = 500 -> 500/2 (half the period) = 250 -> 8 bit representation
signal scount : std_logic_vector(7 downto 0) := "00000000";
signal sclk200 : std_logic := '1';

begin
    process(clk_100mhz)
    begin
        if rising_edge(clk_100mhz) then
                if scount = "11111001" then --249
                    scount <= "00000000";
                    sclk200 <= not sclk200;
                else
                    scount <= std_logic_vector(unsigned(scount) + 1);
                end if;
        end if;
    end process;

    clk_200khz <= sclk200;


end architecture behav;


