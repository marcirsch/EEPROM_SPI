----------------------------------------------------------------------------------
-- Company:     BME
-- Engineer:    Cseh Péter(DM5HMB), Gergely Dániel (T5OCI8), Varga Ákos(BOA0LG)
-- 
-- Create Date: 11.04.2017 21:53:46
-- Design Name: spi
-- Module Name: spi_if - behavioral
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

entity spi_if is
    port
    (
        clk : in std_logic;
        rst : in std_logic;
        
        start : in std_logic;
        pulse : in std_logic;
        valid : in std_logic;
        
        send_data : in std_logic_vector ((SPI_DATA_WIDTH - 1) downto 0);
        rec_data : out std_logic_vector ((SPI_DATA_WIDTH - 1) downto 0);
        
        miso : in std_logic;
        mosi : out std_logic
    );
end spi_if;

architecture behavioral of spi_if is

type t_spi_if_fsm is (idle, shift);
signal spi_if_fsm : t_spi_if_fsm := idle;

signal send : std_logic_vector((SPI_DATA_WIDTH - 1) downto 0) := (others => '0');
signal rec : std_logic_vector((SPI_DATA_WIDTH - 1) downto 0) := (others => '0');

begin

rec_data <= rec;

proc_comm : process(clk)
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            spi_if_fsm <= idle;
        else
            case spi_if_fsm is
            
                when idle =>
                
                    --send <= (others => '0'); --kell ez?
                    --rec <= (others => '0'); --kell ez?
                    
                    if(start = '1') then
                        send <= send_data;
                        
                        spi_if_fsm <= shift;
                    end if;    
                    
                when shift =>
                
                    if(pulse = '1') then
                        --SEND--
                        send <= send((SPI_DATA_WIDTH - 2) downto 0) & '0'; --shift left
                        mosi <= send(SPI_DATA_WIDTH - 1);   --MSB -> mosi
                        
                        --RECEIVE--
                        rec <= rec((SPI_DATA_WIDTH - 2) downto 0) & miso; --shift left, LSB miso
                    end if;
                    
                    if(valid = '1') then
                        spi_if_fsm <= idle;
                    end if;
                    
            end case;
        end if;
    end if;
end process proc_comm;

end behavioral;