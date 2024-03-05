library ieee;
use ieee.std_logic_1164.all;
 
entity tb_clkgen is
END tb_clkgen;
 
architecture behavior of tb_clkgen is
     
    -- Component Declaration for the Unit Under Test (UUT)
     
    component clkgen200 is
    port(
        clk_100mhz : in std_logic;
        clk_200khz : out std_logic 
        );
    end component;
     
    --Inputs
    signal sclk_in : std_logic := '0';
    
     
    --Outputs
    signal sclk_out : std_logic;
     
    -- Clock period definitions
    constant clk_period : time := 10 ns; --100MHZ freq
     
    begin
     
    -- Instantiate the Unit Under Test (UUT)
    uut: clkgen200 port map (
    clk_100mhz => sclk_in,
    clk_200khz => sclk_out
    );
     
    -- Clock process definitions
    clk_process :process
    begin
        sclk_in <= '0';
        wait for clk_period/2;
        sclk_in <= '1';
        wait for clk_period/2;
   end process;
     
--    -- Stimulus process
--    stim_proc: process
--    begin
--    wait for 100 ns;
--    reset <= '1';
--    wait for 100 ns;
--    reset <= '0';
--    wait;
--    end process;
 
end;
