----------------------------------------------------------------------------------
-- Company:     BME
-- Engineer:    Cseh Péter(DM5HMB), Gergely Dániel (T5OCI8), Varga Ákos(BOA0LG)
-- 
-- Create Date: 11.04.2017 21:53:46
-- Design Name: spi
-- Module Name: spi_top - behavioral
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.spi_pkg.all;

entity spi_top is
    port 
    (
        clk : in std_logic;
        per_rst : in std_logic;
        sys_rst : in std_logic;
        
        cfg : in spi_cfg;
        cfg_valid : in std_logic;
        
        dev_sel : in std_logic_vector((SPI_DEVICES - 1) downto 0);
        send_data : in std_logic_vector((SPI_DATA_WIDTH - 1) downto 0);
        rec_data : out std_logic_vector((SPI_DATA_WIDTH - 1) downto 0);
        busy : out std_logic;
        valid : out std_logic;
        en : in std_logic;
        
        miso : in std_logic;
        mosi : out std_logic;
        ss : out std_logic_vector((SPI_DEVICES - 1) downto 0);
        sck : out std_logic
    );
end spi_top;

architecture behavioral of spi_top is

signal rst : std_logic := '0';

signal pulse : std_logic := '0';
signal start : std_logic := '0';
signal w_valid : std_logic := '0';
signal p_ss : std_logic_vector((SPI_DEVICES - 1) downto 0) := (others => '0');

signal cfg_reg : spi_cfg := spi_cfg_default;

begin

--RESET
rst <= (per_rst or sys_rst);

ss <= not(p_ss);
valid <= w_valid;

proc_cfg : process(clk)
begin
    if(rising_edge(clk)) then
        if(cfg_valid = '1') then
            cfg_reg <= cfg;
        end if;
    end if;
end process proc_cfg;

inst_timer : entity work.timer(behavioral)
    port map
    (
        clk => clk,
        rst => rst,
        cfg => cfg_reg,
        busy => busy,
        valid => w_valid,
        start => start,
        en => en,
        dev_sel => dev_sel,
        sck => sck,
        pulse => pulse,
        ss => p_ss
    );
    
inst_spi_if : entity work.spi_if(behavioral)
    port map
    (
        clk => clk,
        rst => rst,
        pulse => pulse,
        start => start,
        valid => w_valid,
        send_data => send_data,
        rec_data => rec_data,
        miso => miso,
        mosi => mosi
    );

end behavioral;
