----------------------------------------------------------------------------------
-- Company:     BME
-- Engineer:    Cseh Péter(DM5HMB), Gergely Dániel (T5OCI8), Varga Ákos(BOA0LG)
-- 
-- Create Date: 14.04.2017 13:36:17
-- Design Name: spi
-- Module Name: spi_timer_sim - sim
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
use work.all;

entity spi_timer_sim is

end spi_timer_sim;

architecture sim of spi_timer_sim is

constant tick : time := 62.5 ns; --16Mhz -> 1/16Mhz = 0.0625 us = 62.5 ns

signal tb_clk : std_logic := '0';
signal tb_rst : std_logic := '0';

signal tb_valid : std_logic := '0';
signal tb_sck_rise : std_logic := '0';
signal tb_sck_fall : std_logic := '0';
signal tb_start : std_logic := '0';

signal tb_busy : std_logic := '0';
signal tb_en : std_logic := '0';
signal tb_dev_sel : std_logic_vector ((SPI_DEVICES - 1) downto 0) := (others => '0');

signal tb_sck : std_logic := '0';
signal tb_ss : std_logic_vector((SPI_DEVICES - 1) downto 0) := (others => '0');

begin

inst_dut : entity work.timer(behavioral)
    port map
    (
        clk => tb_clk,
        rst => tb_rst,
        
        valid => tb_valid,
        sck_rise => tb_sck_rise,
        sck_fall => tb_sck_fall,
        start => tb_start,
        
        busy => tb_busy,
        en => tb_en,
        dev_sel => tb_dev_sel,
        
        sck => tb_sck,
        ss => tb_ss
    );

proc_clk : process
begin
    tb_clk <= '1'; wait for (tick / 2);
    tb_clk <= '0'; wait for (tick / 2);
end process proc_clk;

proc_stim : process
begin
    tb_rst <= '1', '0' after 2*tick;
    tb_en <= '0', '1' after 5*tick, '0' after 6*tick;
    wait;
end process proc_stim;

end sim;
