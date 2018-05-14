library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package spi_pkg is

    constant SPI_DATA_WIDTH : integer := 24;  -- SPI data width needs to be 24 for EEPROM
    constant SPI_CLK_DIV : integer := 2; --SPI divider/2

end package spi_pkg;

