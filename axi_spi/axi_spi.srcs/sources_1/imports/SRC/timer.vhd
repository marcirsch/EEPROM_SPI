----------------------------------------------------------------------------------
-- Company:     BME
-- Engineer:    Rausch Marcell  Sági Tamás
-- 
-- Create Date: 10.04.2018 21:53:46
-- Design Name: spi
-- Module Name: timer - behavioral
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.spi_pkg.all;


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
        
        sck : out std_logic;
        ss : out std_logic
    );
end timer;

architecture behavioral of timer is

signal cntr : integer range 0 to SPI_CLK_DIV-1 := SPI_CLK_DIV-1;

type t_spi_timer_fsm is (idle, transaction);
signal spi_timer_fsm : t_spi_timer_fsm := idle;

signal w_sck : std_logic := '0';

signal sck_cntr : integer range 0 to SPI_DATA_WIDTH*2 + 1 := 0;

begin

sck <= w_sck;

proc_div : process(clk)    
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            cntr <= SPI_CLK_DIV-1;
        else
            if(cntr = SPI_CLK_DIV-1) then
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
                    busy <= '0';
                    sck_cntr <= 0;
                    
                    if(en = '1') then
                        spi_timer_fsm <= transaction;
                        
                        start <= '1';
                        ss <= '1';
                        busy <= '1';
                    else
                        start <= '0';
                        ss <=  '0';
                        busy <= '0';
                    end if;
                    
                when transaction =>
                    if(cntr = SPI_CLK_DIV-1) then
                        sck_cntr <= sck_cntr + 1;
                    end if;
                    
                    case sck_cntr is
                        when 0 =>
                            start <= '0';
                            
                        when (SPI_DATA_WIDTH*2 + 1) =>
                            sck_rise <= '0';
                            sck_fall <= '0';
                            w_sck <= '0';
                            
                            if(cntr = 0) then
                                spi_timer_fsm <= idle;
                                busy <= '0';
                                valid <= '1';
                            end if;                            
                            
                        when others =>    
                        
                            if(cntr = SPI_CLK_DIV-2) then
                            
                                if(w_sck = '1') then
                                    sck_rise <= '0';
                                    sck_fall <= '1';
                                elsif(w_sck = '0') then
                                    sck_rise <= '1';
                                    sck_fall <= '0';
                                end if;
                            elsif(cntr = SPI_CLK_DIV-1) then
                            
                                if(w_sck = '1') then
                                    sck_rise <= '0';
                                    sck_fall <= '0';
                                    w_sck <= '0'; 
                                elsif(w_sck = '0') then
                                    sck_rise <= '0';
                                    sck_fall <= '0';
                                    w_sck <= '1'; 
                                end if;
                            end if;                            
                    end case;
                    
            end case;
            
        end if;
    end if;
end process proc_timer;

end behavioral;