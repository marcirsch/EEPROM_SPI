----------------------------------------------------------------------------------
-- Company:     BME
-- Engineer:    Cseh P�ter(DM5HMB), Gergely D�niel(T5OCI8), Varga �kos(BOA0LG)
-- 
-- Create Date: 11.04.2017 21:53:46
-- Design Name: spi
-- Module Name: spi_top - behavioral
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.spi_pkg.all;

entity spi_top is
    port 
    (
        clk : in std_logic;
        per_rst : in std_logic;
        sys_rst : in std_logic;
        
        send_data : in std_logic_vector((SPI_DATA_WIDTH - 1) downto 0);
        rec_data : out std_logic_vector((SPI_DATA_WIDTH - 1) downto 0);
        
        busy : out std_logic;
        valid : out std_logic;
        en : in std_logic;
        
        miso : in std_logic;
        mosi : out std_logic;
        ss : out std_logic;
        sck : out std_logic
    );
end spi_top;

architecture behavioral of spi_top is

signal rst : std_logic := '0';

signal sck_rise : std_logic := '0';
signal sck_fall : std_logic := '0';
signal start : std_logic := '0';
signal w_valid : std_logic := '0';

signal p_ss : std_logic := '0';

begin

--RESET
rst <= (per_rst or sys_rst);

--Active 0 slave select
ss <= not(p_ss);

valid <= w_valid;

inst_timer : entity work.timer(behavioral)
    port map
    (
        clk => clk,
        rst => rst,
        
        
        valid => w_valid,
        sck_rise => sck_rise,
        sck_fall => sck_fall,
        start => start,
        
        en => en,
        busy => busy,
        
        sck => sck,
        ss => p_ss
    );
    
inst_spi_if : entity work.spi_if(behavioral)
    port map
    (
        clk => clk,
        rst => rst,
        
        start => start,
        sck_rise => sck_rise,
        sck_fall => sck_fall,
        valid => w_valid,
        
        send_data => send_data,
        rec_data => rec_data,
        
        miso => miso,
        mosi => mosi
    );

end behavioral;
