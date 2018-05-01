----------------------------------------------------------------------------------
-- Company:     BME
-- Engineer:    Cseh Péter(DM5HMB), Gergely Dániel(T5OCI8), Varga Ákos(BOA0LG)
-- 
-- Create Date: 11.04.2017 21:53:46
-- Design Name: spi
-- Module Name: timer - behavioral
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.spi_pkg.all;

--Clock freq: 16MHz -> 1 clock period time: 1/16MHz = 0.0625us = 62.5 ns
--SCK freq: max 5 Mhz -> clk / 4 = 16MHz / 4 = 4MHz -> SCK period time: 1 / 4MHz = 250 ns -> 4 clock period time
--SS setup time: min 200 ns -> 250 ns -> 1 SCK period time
--SS hold time: min 200 ns  -> 250 ns -> 1 SCK period time
--data setup time: min 80 ns -> 125 ns -> 2 clk period time
--data hold time: min 80 ns -> 125 ns -> 2 clk period time
--CPOL: 0
--CPHA: 0

entity timer is
    port
    (
        clk : in std_logic;
        rst : in std_logic;
        
        valid : out std_logic;
        sck_rise : out std_logic;
        sck_fall : out std_logic;
        start : out std_logic;
        
        en : in std_logic;
        busy : out std_logic;
        dev_sel : in std_logic_vector ((SPI_DEVICES - 1) downto 0);
        
        sck : out std_logic;
        ss : out std_logic_vector((SPI_DEVICES - 1) downto 0)
    );
end timer;

architecture behavioral of timer is

signal cntr : integer range 0 to 3 := 3;

type t_spi_timer_fsm is (idle, work);
signal spi_timer_fsm : t_spi_timer_fsm := idle;

signal w_sck : std_logic := '0';

signal sck_cntr : integer range 0 to SPI_DATA_WIDTH + 1 := 0;

begin

sck <= w_sck;

proc_div : process(clk)    
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            cntr <= 3;
        else
            if(cntr = 3) then
                cntr <= 0;
            else
                cntr <= cntr + 1;
            end if;
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
            
                when idle =>                
                    valid <= '0';
                    sck_rise <= '0';
                    sck_fall <= '0';
                    w_sck <= '0';
                    busy <= '0';
                    sck_cntr <= 0;
                    
                    if(en = '1') then
                        spi_timer_fsm <= work;
                        
                        start <= '1';
                        ss <= dev_sel;
                        busy <= '1';
                    else
                        start <= '0';
                        ss <= (others => '0');
                        busy <= '0';
                    end if;
                    
                when work =>
                    if(cntr = 2) then
                        sck_cntr <= sck_cntr + 1;
                    end if;
                    
                    case sck_cntr is
                        when 0 =>
                            start <= '0';
                            
                        when (SPI_DATA_WIDTH + 1) =>
                            sck_rise <= '0';
                            sck_fall <= '0';
                            w_sck <= '0';
                            if(cntr = 0) then
                                spi_timer_fsm <= idle;
                                busy <= '0';
                                valid <= '1';
                            end if;                            
                            
                        when others =>
                            case cntr is
                                when 0 => sck_fall <= '1';    
                                when 1 => w_sck <= '0'; sck_fall <= '0';
                                when 2 => sck_rise <= '1'; 
                                when 3 => w_sck <= '1'; sck_rise <= '0';   
                            end case;
                            
                    end case;
                    
            end case;
            
        end if;
    end if;
end process proc_timer;

end behavioral;