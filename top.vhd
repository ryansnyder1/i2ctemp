library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is 
    port(
        CLK_100MHZ : in std_logic;
        rst : in std_logic;
        tmp_sda : inout std_logic;
        tmp_scl : out std_logic;
        leds : out std_logic_vector(7 downto 0)
        --seg : out std_logic_vector(6 downto 0);
        --anodes : out std_logic_vector(3 downto 0);
        --nanodes : out std_logic_vector(3 downto 0);
    );
end top;

architecture behav of top is
    ----component declarations----
    component clkgen200 is
        port(
        clk_100mhz : in std_logic;
        clk_200khz : out std_logic 
        );
    end component clkgen200;

    component i2c_master is
        port(
            clk_200khz : in std_logic;
            rst : in std_logic;
            sda : inout std_logic;
            tmp : out std_logic_vector(7 downto 0);
            sda_dir : inout std_logic;
            scl : out std_logic
        );
    end component i2c_master;

    --7 segment display component declaration goes here

    ----signal declarations----
    signal ssda_dir: std_logic;
    signal sclk200 : std_logic; -- 200 kHz SCL clock signal
    signal stmp : std_logic_vector(7 downto 0); -- 8-bit temperature data result

begin
    clkgen200_inst : clkgen200 port map (
        clk_100mhz => CLK_100MHZ,
        clk_200khz => sclk200
    );

    i2cmaster_inst : i2c_master port map (
        clk_200khz => sclk200,
        rst => rst,
        sda => tmp_sda,
        tmp => stmp,
        sda_dir => ssda_dir,
        scl => tmp_scl;
    );

    --7 segment display component instantiation goes here

    LED <= stmp;  --map 8-bit temperature data to on-board LEDs

end behav;


