----------------------------------------------------------------------------------
-- Company:     BME
-- Engineer:    Cseh P�ter(DM5HMB), Gergely D�niel(T5OCI8), Varga �kos(BOA0LG)
-- 
-- Create Date: 11.04.2017 21:53:46
-- Design Name: spi
-- Module Name: spi_if - behavioral
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.spi_pkg.all;

entity spi_if is
    port
    (
        clk : in std_logic;
        rst : in std_logic;
        
        start : in std_logic;
        sck_rise : in std_logic;
        sck_fall : in std_logic;
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
    
    signal shift_reg : std_logic_vector((SPI_DATA_WIDTH - 1) downto 0) := (others => '0');

begin

    rec_data <= shift_reg;
    
    proc_comm : process(clk)
    begin
        if(rising_edge(clk)) then
            if(rst = '1') then
                spi_if_fsm <= idle;
            else
                case spi_if_fsm is
                
                    when idle =>
                        
                        if(start = '1') then
                            shift_reg <= send_data;
                            
                            spi_if_fsm <= shift;
                        end if;    
                        
                    when shift =>
                    
                        --SEND--
                        if(sck_fall = '1') then --AT25010B EEPROM is sampling the mosi at sck rising edge -> shifting mosi out at falling edge to keep the setup time 
                            mosi <= shift_reg(SPI_DATA_WIDTH - 1);
                        end if;
                        
                        --RECEIVE--
                        if(sck_rise = '1') then --received data is valid on the rising edge of the sck    
                            shift_reg <= shift_reg((SPI_DATA_WIDTH - 2) downto 0) & miso;
                        end if;
                        
                        --DONE--
                        if(valid = '1') then
                            spi_if_fsm <= idle;
                        end if;
                        
                end case;
            end if;
        end if;
    end process proc_comm;

end behavioral;