----------------------------------------------------------------------------------
-- Company:     BME
-- Engineer:    Cseh Péter(DM5HMB), Gergely Dániel (T5OCI8), Varga Ákos(BOA0LG)
-- 
-- Create Date: 11.04.2017 21:53:46
-- Design Name: spi
-- Module Name: spi_pkg - behavioral
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

package spi_pkg is

constant SPI_DATA_WIDTH : integer := 24;
constant SPI_DEVICES : integer := 4;
constant SPI_TIMER_SCALER_WIDTH : integer := 3;

type spi_cfg is record
    cpol : std_logic;
    cpha : std_logic;
    div : std_logic_vector((SPI_TIMER_SCALER_WIDTH - 1) downto 0);
end record spi_cfg;
constant spi_cfg_default : spi_cfg := (cpol => '0', cpha => '0', div => (others => '0'));

end package spi_pkg;

