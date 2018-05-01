----------------------------------------------------------------------------------
-- Company:     BME
-- Engineer:    Cseh Péter(DM5HMB), Gergely Dániel (T5OCI8), Varga Ákos(BOA0LG)
-- 
-- Create Date: 12.04.2017 00:18:43
-- Design Name: spi
-- Module Name: spi_if_sim - behavioral
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

entity spi_if_sim is

end spi_if_sim;

architecture sim of spi_if_sim is

constant tick : time := 62.5 ns; --16Mhz -> 1/16Mhz = 0.0625 us = 62.5 ns
signal test_miso : std_logic_vector((SPI_DATA_WIDTH - 1) downto 0) := x"AA_AA_AA";
constant test_send : std_logic_vector((SPI_DATA_WIDTH - 1) downto 0) := x"55_55_55";


signal tb_clk : std_logic := '0';
signal tb_rst : std_logic := '0';

signal tb_start : std_logic := '0';
signal tb_sck_rise : std_logic := '0';
signal tb_sck_fall : std_logic := '0';
signal tb_valid : std_logic := '0';

signal tb_send_data : std_logic_vector((SPI_DATA_WIDTH - 1) downto 0) := test_send;
signal tb_rec_data : std_logic_vector((SPI_DATA_WIDTH - 1) downto 0) := (others => '0');

signal tb_miso : std_logic := '0';
signal tb_mosi : std_logic := '0';

begin

dut_spi_if : entity work.spi_if(behavioral)
    port map
    (
        clk => tb_clk,
        rst => tb_rst,
        
        
        start => tb_start,
        sck_rise => tb_sck_rise,
        sck_fall => tb_sck_fall,
        valid => tb_valid,
        
        send_data => tb_send_data,
        rec_data => tb_rec_data,
        
        miso => tb_miso,
        mosi => tb_mosi
    );
    
proc_clk : process
begin
    tb_clk <= '1'; wait for (tick / 2);
    tb_clk <= '0'; wait for (tick / 2);
end process proc_clk;

--proc_pulse : process(tb_clk)
--    variable cntr : integer range 0 to 15 := 0;
--begin
--    if(rising_edge(tb_clk)) then
--        if(tb_rst = '1') then
--            cntr := 0;
--        else
--            if(cntr = 15) then
--                tb_pulse <= '1';
                
--                cntr := 0;
--            else
--                tb_pulse <= '0';
--                cntr := cntr + 1;
--            end if;
--        end if;
--    end if;
--end process;

--proc_pulse_cnt : process(tb_clk)
--    variable cntr : integer range 0 to (SPI_DATA_WIDTH + 1) := SPI_DATA_WIDTH;
--begin
--    if(rising_edge(tb_clk)) then
--        if(tb_rst = '1') then
--            cntr := SPI_DATA_WIDTH;
--        else
--            if(tb_pulse = '1') then
--                case cntr is
--                    when (SPI_DATA_WIDTH) => tb_start <= '1'; tb_valid <= '0'; cntr := cntr - 1;       
--                    when 0 =>                tb_start <= '0'; tb_valid <= '1'; cntr := (SPI_DATA_WIDTH + 1);
--                    when others =>           tb_start <= '0'; tb_valid <= '0'; cntr := cntr - 1;                  
--                end case;
                
--                tb_miso <= test_miso(SPI_DATA_WIDTH - 1);
--                test_miso <= test_miso((SPI_DATA_WIDTH - 2) downto 0) & '0';
--            end if;
--        end if;
--    end if;
--end process proc_pulse_cnt;

--proc_stim : process
--begin
--    tb_rst <= '0', '1' after 10*tick, '0' after 20*tick;
--wait;
--end process proc_stim;

end sim;
