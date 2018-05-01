--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:38:34 05/08/2017
-- Design Name:   
-- Module Name:   D:/BME/MSC1/RA/HF/axi/axi_1/axi_spi_test.vhd
-- Project Name:  axi_1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: axi_spi_top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY axi_spi_test IS
END axi_spi_test;
 
ARCHITECTURE behavior OF axi_spi_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT axi_spi_top
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         S_AXI_AWADDR : IN  std_logic_vector(31 downto 0);
         S_AXI_AWVALID : IN  std_logic;
         S_AXI_AWREADY : OUT  std_logic;
         S_AXI_WDATA : IN  std_logic_vector(31 downto 0);
         S_AXI_WSTRB : IN  std_logic_vector(3 downto 0);
         S_AXI_WVALID : IN  std_logic;
         S_AXI_WREADY : OUT  std_logic;
         S_AXI_ARADDR : IN  std_logic_vector(31 downto 0);
         S_AXI_ARVALID : IN  std_logic;
         S_AXI_ARREADY : OUT  std_logic;
         S_AXI_RDATA : OUT  std_logic_vector(31 downto 0);
         S_AXI_RRESP : OUT  std_logic_vector(1 downto 0);
         S_AXI_RVALID : OUT  std_logic;
         S_AXI_RREADY : IN  std_logic;
         S_AXI_BRESP : OUT  std_logic_vector(1 downto 0);
         S_AXI_BVALID : OUT  std_logic;
         S_AXI_BREADY : IN  std_logic;
         SPI_MISO : IN  std_logic;
         SPI_MOSI : OUT  std_logic;
         SPI_SS : OUT  std_logic;
         SPI_SCK : OUT  std_logic
        );
    END COMPONENT;
    
    --    input                SI;                             // serial data input
    --    input                SCK;                            // serial data clock
    --    input                CS_N;                           // chip select - active low
    --    input                WP_N;                           // write protect pin - active low
    --    input                HOLD_N;                         // interface suspend - active low
    --    input                RESET;                          // model reset/power-on reset
    --    output               SO;   
    
    COMPONENT M25AA010A
    PORT(
        SI : IN std_logic;
        SCK : IN std_logic;
        CS_N : IN std_logic;
        WP_N : IN std_logic;
        HOLD_N : IN std_logic;
        RESET : IN std_logic;
        SO : OUT std_logic
    );
    END COMPONENT;
    
    
   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal S_AXI_AWADDR : std_logic_vector(31 downto 0) := (others => '0');
   signal S_AXI_AWVALID : std_logic := '0';
   signal S_AXI_WDATA : std_logic_vector(31 downto 0) := (others => '0');
   signal S_AXI_WSTRB : std_logic_vector(3 downto 0) := (others => '0');
   signal S_AXI_WVALID : std_logic := '0';
   signal S_AXI_ARADDR : std_logic_vector(31 downto 0) := (others => '0');
   signal S_AXI_ARVALID : std_logic := '0';
   signal S_AXI_RREADY : std_logic := '0';
   signal S_AXI_BREADY : std_logic := '0';
   signal SPI_MISO : std_logic := '0';
   
   signal S_WP_N : std_logic := '1';
   signal S_HOLD_N: std_logic := '1';

 	--Outputs
   signal S_AXI_AWREADY : std_logic;
   signal S_AXI_WREADY : std_logic;
   signal S_AXI_ARREADY : std_logic;
   signal S_AXI_RDATA : std_logic_vector(31 downto 0);
   signal S_AXI_RRESP : std_logic_vector(1 downto 0);
   signal S_AXI_RVALID : std_logic;
   signal S_AXI_BRESP : std_logic_vector(1 downto 0);
   signal S_AXI_BVALID : std_logic;
   signal SPI_MOSI : std_logic;
   signal SPI_SS : std_logic;
   signal SPI_SCK : std_logic;
   

   -- Clock period definitions
   constant CLK_period : time := 62.5 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: axi_spi_top PORT MAP (
          CLK => CLK,
          RST => RST,
          S_AXI_AWADDR => S_AXI_AWADDR,
          S_AXI_AWVALID => S_AXI_AWVALID,
          S_AXI_AWREADY => S_AXI_AWREADY,
          S_AXI_WDATA => S_AXI_WDATA,
          S_AXI_WSTRB => S_AXI_WSTRB,
          S_AXI_WVALID => S_AXI_WVALID,
          S_AXI_WREADY => S_AXI_WREADY,
          S_AXI_ARADDR => S_AXI_ARADDR,
          S_AXI_ARVALID => S_AXI_ARVALID,
          S_AXI_ARREADY => S_AXI_ARREADY,
          S_AXI_RDATA => S_AXI_RDATA,
          S_AXI_RRESP => S_AXI_RRESP,
          S_AXI_RVALID => S_AXI_RVALID,
          S_AXI_RREADY => S_AXI_RREADY,
          S_AXI_BRESP => S_AXI_BRESP,
          S_AXI_BVALID => S_AXI_BVALID,
          S_AXI_BREADY => S_AXI_BREADY,
          SPI_MISO => SPI_MISO,
          SPI_MOSI => SPI_MOSI,
          SPI_SS => SPI_SS,
          SPI_SCK => SPI_SCK
        );
        
    eeprom: M25AA010A port map(SPI_MOSI ,SPI_SCK,SPI_SS ,S_WP_N ,S_HOLD_N,RST ,SPI_MISO);
    
   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
   
   proc_miso : process(SPI_SCK)
   begin
        if(rising_edge(SPI_SCK)) then
            SPI_MISO <= not(SPI_MISO);
        end if;
   end process proc_miso;
   
   proc_axi_r_ready : process(CLK)
   begin
    if(rising_edge(CLK)) then
        if(S_AXI_RVALID = '1') then
            S_AXI_RREADY <= '1';
        else
            S_AXI_RREADY <= '0';
        end if;
    end if;
   end process proc_axi_r_ready;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_period*2;

      -- insert stimulus here 
      -- WRITE TRANSACTION
     S_AXI_AWADDR <= X"FA000001";
     S_AXI_AWVALID <= '1';
     S_AXI_WDATA <= X"aabb02cc"; --WRITE opcode: 0000 0010
     S_AXI_WVALID <= '1';
     wait for 2*CLK_period;
     S_AXI_AWADDR <= X"00000000"; 
     S_AXI_WDATA <= X"00000000";
     S_AXI_AWVALID <= '0'; 
       S_AXI_WVALID <= '0'; 
     wait for 2*CLK_period;
     
     -- READ TRANSACTION
     S_AXI_ARADDR <= X"AA400300"; --READ opcode: 0000 0011
     S_AXI_ARVALID <= '1';
     wait for 2*CLK_period;
     S_AXI_ARADDR <= X"00000000"; 
     S_AXI_ARVALID <= '0';
     wait for 2*CLK_period;
  
    -- WRITE + READ TRANSACTION
     S_AXI_AWADDR <= X"30000001";
     S_AXI_AWVALID <= '1';
     S_AXI_WDATA <= X"aabb02cc"; --WRITE opcode: 0000 0010
     S_AXI_WVALID <= '1';
     
     S_AXI_ARADDR <= X"03400000"; --READ opcode: 0000 0011
     S_AXI_ARVALID <= '1';
     wait for 2*CLK_period;
     S_AXI_AWADDR <= X"00000000"; 
     S_AXI_WDATA <= X"00000000";
     S_AXI_AWVALID <= '0'; 
       S_AXI_WVALID <= '0'; 
     
     S_AXI_ARADDR <= X"00000000"; 
     S_AXI_ARVALID <= '0';

     wait for 2*CLK_period;
     
     wait for 200*CLK_period;
    -- READ TRANSACTION
     S_AXI_ARADDR <= X"FA400300"; --READ opcode: 0000 0011
     S_AXI_ARVALID <= '1';
     wait for 2*CLK_period;
     S_AXI_ARADDR <= X"00000000"; 
     S_AXI_ARVALID <= '0';
     wait for 2*CLK_period;
    

      wait;
   end process;

END;
