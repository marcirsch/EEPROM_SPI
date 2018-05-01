----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:23:38 05/07/2017 
-- Design Name: 
-- Module Name:    axi_spi_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity axi_spi_top is
generic
(
	SPI_DATA_WIDTH : integer := 8 ;
	SPI_CLK_DIV : integer := 4
	);

Port ( 
	 --AXI
    -- Clock and Reset--
    CLK : in std_logic;
    RST : in std_logic;

      -- Write Address Channel--
      S_AXI_AWADDR : in std_logic_vector(31 downto 0);
      S_AXI_AWVALID : in std_logic;
      S_AXI_AWREADY : out std_logic;
      
      -- Write Data Channel--
      S_AXI_WDATA : in std_logic_vector(31 downto 0);
      S_AXI_WSTRB : in std_logic_vector(3 downto 0);
      S_AXI_WVALID : in std_logic;
      S_AXI_WREADY : out std_logic;
      
      -- Read Address Channel--
      S_AXI_ARADDR : in std_logic_vector(31 downto 0);
      S_AXI_ARVALID : in std_logic;
      S_AXI_ARREADY : out std_logic;
      
      -- Read Data Channel--
      S_AXI_RDATA : out std_logic_vector(31 downto 0);
      S_AXI_RRESP : out std_logic_vector(1 downto 0);
      S_AXI_RVALID : out std_logic;
      S_AXI_RREADY : in std_logic;
      
      -- Write Response Channel--
      S_AXI_BRESP : out std_logic_vector(1 downto 0);
      S_AXI_BVALID : out std_logic;
      S_AXI_BREADY : in std_logic;

      --SPI
      SPI_MISO : in std_logic;
      SPI_MOSI : out std_logic;
      SPI_SS : out std_logic;
      SPI_SCK : out std_logic
      );
end axi_spi_top;

architecture Behavioral of axi_spi_top is

component spi_top
port (
    clk : in std_logic;
    per_rst : in std_logic;
    sys_rst : in std_logic;
    
    send_data : in std_logic_vector((SPI_DATA_WIDTH - 1) downto 0);
    rec_data : out std_logic_vector((SPI_DATA_WIDTH - 1) downto 0);
    
    busy : out std_logic;
    valid : out std_logic;
    en : in std_logic;
    
    miso : in std_logic;
    mosi : out std_logic;
    ss : out std_logic;
    sck : out std_logic
);
end component;

component axi
	port (
	--AXI
	-- Clock and Reset--
	  S_AXI_ACLK : in std_logic;
	  S_AXI_ARESETN : in std_logic;
	  
	  -- Write Address Channel--
	  S_AXI_AWADDR : in std_logic_vector(31 downto 0);
	  S_AXI_AWVALID : in std_logic;
	  S_AXI_AWREADY : out std_logic;
	  
	  -- Write Data Channel--
	  S_AXI_WDATA : in std_logic_vector(31 downto 0);
	  S_AXI_WSTRB : in std_logic_vector(3 downto 0);
	  S_AXI_WVALID : in std_logic;
	  S_AXI_WREADY : out std_logic;
	  
	  -- Read Address Channel--
	  S_AXI_ARADDR : in std_logic_vector(31 downto 0);
	  S_AXI_ARVALID : in std_logic;
	  S_AXI_ARREADY : out std_logic;
	  
	  -- Read Data Channel--
	  S_AXI_RDATA : out std_logic_vector(31 downto 0);
	  S_AXI_RRESP : out std_logic_vector(1 downto 0);
	  S_AXI_RVALID : out std_logic;
	  S_AXI_RREADY : in std_logic;
	  
	  -- Write Response Channel--
	  S_AXI_BRESP : out std_logic_vector(1 downto 0);
	  S_AXI_BVALID : out std_logic;
	  S_AXI_BREADY : in std_logic;
	  
	--SPI
	  spi_send_data : out std_logic_vector(SPI_DATA_WIDTH-1 downto 0);
	  spi_rec_data : in std_logic_vector(SPI_DATA_WIDTH-1 downto 0);
	  spi_busy : in std_logic;
	  spi_valid : in std_logic;
	  spi_en : out std_logic
);
end component;

--signal s_clk : std_logic;
signal s_send_data : std_logic_vector(SPI_DATA_WIDTH-1 downto 0);
signal s_rec_data : std_logic_vector(SPI_DATA_WIDTH-1 downto 0);
signal s_busy : std_logic;
signal s_valid : std_logic;
signal s_en : std_logic;

begin

inst_spi_top : spi_top
port map(
		clk => CLK,
		per_rst => RST, 	--TODO
		sys_rst =>  RST, 	--TODO	

		send_data =>  s_send_data,
		rec_data =>  s_rec_data,

		busy =>  s_busy,
		valid =>  s_valid,
		en =>  s_en,

		miso => SPI_MISO,
		mosi => SPI_MOSI,
		ss =>  SPI_SS,
		sck => SPI_SCK 
	  );

inst_axi : axi
port map(
		-- Clock and Reset--
		S_AXI_ACLK => CLK,
		S_AXI_ARESETN => RST,

		-- Write Address Channel--
		S_AXI_AWADDR => S_AXI_AWADDR,
		S_AXI_AWVALID => S_AXI_AWVALID,
		S_AXI_AWREADY => S_AXI_AWREADY,

		-- Write Data Channel--
		S_AXI_WDATA => S_AXI_WDATA,
		S_AXI_WSTRB => S_AXI_WSTRB,
		S_AXI_WVALID => S_AXI_WVALID,
		S_AXI_WREADY => S_AXI_WREADY,

		-- Read Address Channel--
		S_AXI_ARADDR => S_AXI_ARADDR,
		S_AXI_ARVALID => S_AXI_ARVALID,
		S_AXI_ARREADY => S_AXI_ARREADY,

		-- Read Data Channel--
		S_AXI_RDATA => S_AXI_RDATA,
		S_AXI_RRESP => S_AXI_RRESP,
		S_AXI_RVALID => S_AXI_RVALID,
		S_AXI_RREADY => S_AXI_RREADY,

		-- Write Response Channel--
		S_AXI_BRESP => S_AXI_BRESP,
		S_AXI_BVALID => S_AXI_BVALID,
		S_AXI_BREADY => S_AXI_BREADY,

		--SPI
		spi_send_data => s_send_data,
		spi_rec_data => s_rec_data,
		spi_busy => s_busy,
		spi_valid => s_valid,
		spi_en => s_en
	);

end Behavioral;

