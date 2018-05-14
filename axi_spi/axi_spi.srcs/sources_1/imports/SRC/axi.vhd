library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.spi_pkg.all;

entity axi is
  generic
  (
    PER_ADDR : std_logic_vector(7 downto 0) := X"FA"
  );
  port
  (
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
end axi;

architecture behavioral of axi is


--Belso WRITE jelek--
signal w_addr : std_logic_vector(31 downto 0) := (others => '0'); --írási cím
signal w_addr_valid : std_logic := '0'; --Jelzi, ha van érvényes írási cím

signal w_data : std_logic_vector(31 downto 0) := (others => '0'); --írási adat
signal w_data_valid : std_logic := '0'; --Jelzi, ha van érvényes  írási adat

signal w_en : std_logic := '0'; --jelzi, ha lehet írni

--Belso READ jelek--
signal r_addr : std_logic_vector(31 downto 0) := (others => '0'); --olvasási cím
signal r_addr_valid : std_logic := '0'; --Jelzi, ha van érvényes olvasási cím

signal r_data : std_logic_vector(31 downto 0) := (others => '0'); --olvasási adat
signal r_data_valid : std_logic := '0'; --Jelzi, ha van érvényes olvasási adat 

signal r_en : std_logic := '0'; --jelzi, ha lehet olvasni: 

begin

----WRITE----

--Nem tudjuk, hogy sikeres-e az �tvitel
S_AXI_BRESP <= "00";
S_AXI_BVALID <= '0';

--WRITE ADDR kezelo process--
proc_write_addr : process (S_AXI_ACLK)
begin
    if(rising_edge(S_AXI_ACLK)) then
        if(S_AXI_ARESETN = '1') then
            w_addr_valid <= '0'; --reset addr valid signal 
        else
            if(S_AXI_AWVALID = '1' and S_AXI_AWADDR(31 downto 24) = PER_ADDR) then --érvényes cím esetén cím elvétele majd addr_valid jelzés
                --Beolvasom a címet
                w_addr <= S_AXI_AWADDR;
                w_addr_valid <= '1';
                
                --Jelzek, hogy el lett véve
                S_AXI_AWREADY <= '1';
            else
            
                S_AXI_AWREADY <= '0'; --minden más órajelnél 0
                
                if(w_en = '1' and spi_busy = '0') then
                    w_addr_valid <= '0';
                end if;
                
            end if;
            
        end if;
    end if;
end process proc_write_addr;

--WRITE DATA kezelo process--

proc_write_data : process (S_AXI_ACLK)
begin
    if(rising_edge(S_AXI_ACLK)) then
        if(S_AXI_ARESETN = '1') then
            w_data_valid <= '0';
        else
            if(S_AXI_WVALID = '1') then --érvényes adat esetén adat elvétele majd data_valid jelzés
                --Beolvasom az érvényes adatot
                w_data <= S_AXI_WDATA;
                w_data_valid <= '1';
                
                --Jelzek, hogy elvettem az adatot
                S_AXI_WREADY <= '1';
            else
            
                S_AXI_WREADY <= '0'; --Minden más órajelnél 0
                               
                if(w_en = '1' and spi_busy = '0') then
                    w_data_valid <= '0';
                end if;
                
            end if;

        end if;
    end if;
end process proc_write_data;

--WRITE ENABLE--
w_en <= w_addr_valid and w_data_valid;



----READ----

--Nem tudjuk, hogy sikeres-e az �tvitel
S_AXI_RRESP <= "00";

--READ ADDR kezelo process--
proc_read_addr : process(S_AXI_ACLK)
begin
    if(rising_edge(S_AXI_ACLK)) then
        if(S_AXI_ARESETN = '1') then
            r_addr_valid <= '0';
        else
            if(S_AXI_ARVALID = '1' and S_AXI_ARADDR(31 downto 24) = PER_ADDR) then --érvényes cím esetén cím elvétele majd data_valid jelzés
                --cím beolvasása
                r_addr <= S_AXI_ARADDR;
                r_addr_valid <= '1';
                
                --Jelzek, hogy elvettem a címet
                S_AXI_ARREADY <= '1';
            else
            
                S_AXI_ARREADY <= '0'; --Minden más órajelnél 0
                
                if(r_en = '1' and w_en = '0' and spi_busy = '0') then
                    r_addr_valid <= '0';
                end if;
            end if;
            
        end if;
    end if;
end process proc_read_addr;

--READ DATA kezelo process--

proc_read_data : process(S_AXI_ACLK)
begin
   if(rising_edge(S_AXI_ACLK)) then
       if(S_AXI_ARESETN = '1') then
            r_data_valid <= '0';
       else
            --Adat beolvas�s
            if(spi_valid = '1') then --érvényes adat esetén adat elvétele majd data_valid jelzés
                r_data <= (31 downto SPI_DATA_WIDTH => '0')&spi_rec_data; --3*8bit írás spi-ra [jelzés,cím,adat]
                r_data_valid <= '1';
            end if;
            
            --Adat kiadása MASTER-nek
            if(r_data_valid = '1') then
               S_AXI_RDATA <= r_data; 
               S_AXI_RVALID <= '1';
            end if;
            
            --Érvényes jelzés törlése
            if(S_AXI_RREADY = '1' and spi_valid = '0') then 
                r_data_valid <= '0';
                S_AXI_RVALID <= '0';
            end if;
       end if;
   end if;
end process proc_read_data;

--READ ENABLE--
    --Ha van olvasái cím, akkor lehet olvasni
r_en <= r_addr_valid;

----SPI----

--SPI--VEZÉRLO
proc_spi : process (S_AXI_ACLK)
    begin
   if(rising_edge(S_AXI_ACLK)) then
       if(S_AXI_ARESETN = '1') then
            spi_en <= '0';
       else
       
            --SPI engedélyezés--
            if((w_en = '1' or r_en = '1') and spi_busy = '0') then --spi engedélyezése írás vagy olvasás esetén
                spi_en <= '1';
            else
                spi_en <= '0';
            end if;
            
            --ÍRÁS
            if(w_en = '1' and spi_busy = '0') then
                --SPI k�ld�si adatvonal
                spi_send_data <= w_data(SPI_DATA_WIDTH-1 downto 0);
            end if;
            
            --OLVASáS--
            if(r_en = '1' and w_en = '0' and spi_busy = '0') then
                spi_send_data <= (15 downto 0 => '0')&r_data(31 downto 24);
      
            end if;
            
       end if;
   end if;
end process proc_spi;

end behavioral;