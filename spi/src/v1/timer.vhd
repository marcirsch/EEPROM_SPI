----------------------------------------------------------------------------------
-- Company:     BME
-- Engineer:    Cseh Péter(DM5HMB), Gergely Dániel (T5OCI8), Varga Ákos(BOA0LG)
-- 
-- Create Date: 11.04.2017 21:53:46
-- Design Name: spi
-- Module Name: timer - behavioral
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.spi_pkg.all;

--SS setup time: min 200 ns
--SS hold time: min 200 ns
--SCK freq: max 5 Mhz -> 4Mhz
--CPOL: 0
--CPHA: 0

entity timer is
    port
    (
        clk : in std_logic;
        rst : in std_logic;
        
        cfg : in spi_cfg;
        
        busy : out std_logic;
        
        valid : out std_logic;
        pulse : out std_logic;
        start : out std_logic;
        
        en : in std_logic;
        dev_sel : in std_logic_vector ((SPI_DEVICES - 1) downto 0);
        
        sck : out std_logic;
        ss : out std_logic_vector((SPI_DEVICES - 1) downto 0)
    );
end timer;

architecture behavioral of timer is

type t_spi_timer_fsm is (idle, work);
signal spi_timer_fsm : t_spi_timer_fsm := idle;

signal cntr : integer range 0 to (SPI_DATA_WIDTH - 1) := 0;

signal scaler_cntr : std_logic_vector( ((2 ** SPI_TIMER_SCALER_WIDTH) - 1) downto 0 ) := (others => '0'); 
signal div_clk : std_logic := '0';

signal pulse_rise : std_logic := '0';
signal pulse_fall : std_logic := '0';
signal div : integer range 0 to ((2 ** SPI_TIMER_SCALER_WIDTH) - 1) := 0;

begin

div <= to_integer(unsigned(cfg.div));

proc_div : process(clk)
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            scaler_cntr <= (others => '0');
        else
            scaler_cntr <= std_logic_vector(unsigned(scaler_cntr) + 1);
        end if;
    end if; 
end process proc_div;

proc_timer : process(clk)
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            spi_timer_fsm <= idle;
        else
            
            case spi_timer_fsm is
            
                when idle => --egy órajel késleltetést okoz a state váltás
                
                    valid <= '0';
                    pulse <= '0';
                    cntr <= 0;
                    
                    if(en = '1') then
                        ss <= (to_integer(unsigned(dev_sel)) => '0', others => '1'); --Slave select
                        busy <= '1';
                        start <= '1';
                    else
                        ss <= (others => '1');
                        busy <= '0';
                        start <= '0';
                    end if;
                    
                when work =>
                    
                
            end case;
            
        end if;
    end if;
end process proc_timer;

end behavioral;
