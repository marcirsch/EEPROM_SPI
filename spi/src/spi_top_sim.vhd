----------------------------------------------------------------------------------
-- Company:     BME
-- Engineer:    Cseh Péter(DM5HMB), Gergely Dániel(T5OCI8), Varga Ákos(BOA0LG)
-- 
-- Create Date: 14.04.2017 14:46:37
-- Design Name: spi
-- Module Name: spi_top_sim - sim
----------------------------------------------------------------------------------

use work.spi_pkg.all;
use work.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity spi_top_sim is

end spi_top_sim;

architecture sim of spi_top_sim is

    constant tick : time := 62.5 ns; --16Mhz -> 1/16Mhz = 0.0625 us = 62.5 ns
    
    signal tb_clk : std_logic := '0';
    signal tb_per_rst : std_logic := '0';
    signal tb_sys_rst : std_logic := '0';
    
    signal tb_dev_sel : std_logic_vector((SPI_DEVICES - 1) downto 0) := (others => '0');
    signal tb_send_data : std_logic_vector((SPI_DATA_WIDTH - 1) downto 0) := x"AA_55_AA";
    signal tb_rec_data : std_logic_vector((SPI_DATA_WIDTH - 1) downto 0) := (others => '0');
    signal tb_busy : std_logic := '0';
    signal tb_valid : std_logic := '0';
    signal tb_en : std_logic := '0';
    
    signal tb_miso : std_logic := '0';
    signal tb_mosi : std_logic := '0';
    signal tb_ss : std_logic_vector((SPI_DEVICES - 1) downto 0) := (others => '0');
    signal tb_sck : std_logic := '0';

begin

    inst_dut : entity work.spi_top(behavioral)
        port map
        (
            clk => tb_clk,
            per_rst => tb_per_rst,
            sys_rst => tb_sys_rst,
            
            dev_sel => tb_dev_sel,
            send_data => tb_send_data,
            rec_data => tb_rec_data,
            busy => tb_busy,
            valid => tb_valid,
            en => tb_en,
            
            miso => tb_miso,
            mosi => tb_mosi,
            ss => tb_ss,
            sck => tb_sck
        );
    
    proc_clk : process
    begin
        tb_clk <= '1'; wait for (tick / 2);
        tb_clk <= '0'; wait for (tick / 2);
    end process proc_clk;
    
    proc_miso : process
    begin
        tb_miso <= '1'; wait for 4*tick;
        tb_miso <= '0'; wait for 4*tick;
        tb_miso <= '0'; wait for 4*tick;
        tb_miso <= '1'; wait for 4*tick;
    end process;
    
    proc_stim : process
    begin
        tb_per_rst <= '1', '0' after 2*tick;
        tb_dev_sel <= "1";
        tb_en <= '0', '1' after 10*tick, '0' after 11*tick;
        wait;
    end process;

end sim;
