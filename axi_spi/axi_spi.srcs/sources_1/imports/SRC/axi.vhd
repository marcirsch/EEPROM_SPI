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


signal read_en : std_logic := '0';  --jelzi, ha lehet olvasni: be�rkezett az �r�si c�m

--Belso WRITE jelek--
signal w_addr : std_logic_vector(31 downto 0) := (others => '0'); --�r�si c�m t�rol�
signal w_addr_valid : std_logic := '0'; --Jelzi, ha van �rv�nyes �r�si c�m

signal w_data : std_logic_vector(31 downto 0) := (others => '0'); --�r�si adat t�rol�
signal w_data_valid : std_logic := '0'; --Jelzi, ha van �rv�nyes olvas�si c�m

signal w_en : std_logic := '0'; --jelzi, ha lehet �rni: be�rkezett az �r�si c�m �s az adat 

--Belso READ jelek--
signal r_addr : std_logic_vector(31 downto 0) := (others => '0'); --olvas�si c�m t�rol�
signal r_addr_valid : std_logic := '0'; --Jelzi, ha van �rv�nyes olvas�si c�m

signal r_data : std_logic_vector(31 downto 0) := (others => '0'); --olvas�si adat t�rol�
signal r_data_valid : std_logic := '0'; --Jelzi, ha van �rv�nyes olvas�si adat 

signal r_en : std_logic := '0'; --jelzi, ha lehet olvasni: be�rkezett az olvas�si c�m (az olvas�si adatot ebbe nem kell belevenni, azt nem az AXI MASTER-tol kapjuk)

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
            --w_addr <= (others => '0'); --El�g a vez�rlo jelet resetelni
            w_addr_valid <= '0';
        else
            if(S_AXI_AWVALID = '1' and S_AXI_AWADDR(31 downto 24) = PER_ADDR) then --Ha van �rv�nyes c�m, akkor elveszem a c�met �s jelzem, hogy elvettem
                --Beolvasom a c�met, van �rv�nyes c�m
                w_addr <= S_AXI_AWADDR;
                w_addr_valid <= '1';
                
                --Jelzek, hogy elvettem
                S_AXI_AWREADY <= '1';
            else
            
                S_AXI_AWREADY <= '0'; --Minden m�s esetben ez '0', csak akkor '1' ha elveszek egy c�met
                
                --null�zni is kell valamikor a "w_addr_valid" jelet ( pl k�vetkezo SPI kommunik�ci�n�l, amikor kiadjuk annak "en" jel�t, ez ut�n m�r nem igaz az, hogy �rv�nyes a c�m�nk)
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
            --w_data <= (others => '0'); --El�g a vez�rlo jelet resetelni
            w_data_valid <= '0';
        else
            if(S_AXI_WVALID = '1') then --Ha van �rv�nyes adat, akkor elveszem az adatot �s jelzem, hogy elvettem
                --Beolvasom az adatot, van �rv�nyes adat
                w_data <= S_AXI_WDATA;
                w_data_valid <= '1';
                
                --Jelzek, hogy elvettem az adatot
                S_AXI_WREADY <= '1';
            else
            
                S_AXI_WREADY <= '0'; --Minden m�s esetben ez '0', csak akkor '1' ha elveszek egy adatot
                
                --null�zni is kell valamikor a "w_data_valid" jelet ( pl k�vetkezo SPI kommunik�ci�n�l, amikor kiadjuk annak "en" jel�t, ez ut�n m�r nem igaz az, hogy �rv�nyes a c�m�nk)                
                if(w_en = '1' and spi_busy = '0') then
                    w_data_valid <= '0';
                end if;
                
            end if;

        end if;
    end if;
end process proc_write_data;

--WRITE ENABLE--
    --Jelzi, ha van �rv�nyes �r�si c�m �s �r�si adat teh�t lehet �rni
w_en <= w_addr_valid and w_data_valid;



----READ----

--Nem tudjuk, hogy sikeres-e az �tvitel
S_AXI_RRESP <= "00";

--READ ADDR kezelo process--
proc_read_addr : process(S_AXI_ACLK)
begin
    if(rising_edge(S_AXI_ACLK)) then
        if(S_AXI_ARESETN = '1') then
            --r_addr <= (others => '0'); --El�g a vez�rlo jelet resetelni
            r_addr_valid <= '0';
        else
            if(S_AXI_ARVALID = '1' and S_AXI_ARADDR(31 downto 24) = PER_ADDR) then --Ha van �rv�nyes c�m, akkor elveszem a c�met �s jelzem, hogy elvettem
                --Beolvasom a c�met, �s van �rv�nyes c�m
                r_addr <= S_AXI_ARADDR;
                r_addr_valid <= '1';
                
                --Jelzek, hogy elvettem a c�met
                S_AXI_ARREADY <= '1';
            else
            
                S_AXI_ARREADY <= '0'; --Minden m�s esetben ez '0', csak akkor '1' ha elveszek egy c�met
                
                --null�zni is kell valamikor a "r_addr_valid" jelet ( pl k�vetkezo SPI kommunik�ci�n�l, amikor kiadjuk annak "en" jel�t, ez ut�n m�r nem igaz az, hogy �rv�nyes a c�m�nk)
                if(r_en = '1' and w_en = '0' and spi_busy = '0') then
                    r_addr_valid <= '0';
                end if;
            end if;
            
        end if;
    end if;
end process proc_read_addr;

--READ DATA kezelo process--
    --A "S_AXI_RRESP" jel jelzi, ha az �tvitel siker�lt-e. Ezt �gy k�ne meghajtani, hogyha olvas�s volt az elozo kommunik�ci� akkor sikeres, ha �r�s, akkor nem, hiszen ekkor is olvas az SPI csak nem arr�l a c�mrol amit a MASTER v�r
proc_read_data : process(S_AXI_ACLK)
begin
   if(rising_edge(S_AXI_ACLK)) then
       if(S_AXI_ARESETN = '1') then
            --r_data <= (others => '0'); --El�g a vez�rlo jelet resetelni
            r_data_valid <= '0';
       else
            --Adat beolvas�s
            if(spi_valid = '1') then --Ha az SPI-nak van �rv�nyes adata, akkor beolvasom azt, �s elt�rolom, hogy van �rv�nyes adat 
                r_data <= (31 downto SPI_DATA_WIDTH => '0')&spi_rec_data; --konkaten�l�s: felso 8 bit '0', az als� 24 bit az adat (itt lehet, hogy �gy k�ne, hogy a felso 24 bit nulla �s az als� 8 az adat, mert �gyis csak ez az �rv�nyes)
                r_data_valid <= '1';
            end if;
            
            --Adat kiad�sa MASTER-nek
            if(r_data_valid = '1') then --Itt igaz�b�l bele k�ne venni, hogy ha az "spi_valid" '1' akkor is kiadjuk a valid jelet, csak akkor nem az "r_data" lenne az adat, hanem a "x"00" & spi_rec_data". Ez egy �rajel k�s�st jelent
               S_AXI_RDATA <= r_data; 
               S_AXI_RVALID <= '1';
            end if;
            
            --Visszaveszem az �rv�nyes jelet
            if(S_AXI_RREADY = '1' and spi_valid = '0') then --Ha a MASTER elvette az adatot �s az spi-on nem �rkezett �j adat, akkor m�r nem �rv�nyes az "r_data". (Megj.: Az "spi_valid = '0'" n�lk�l szembehajt�s lehetne a buszon)
                r_data_valid <= '0';
                S_AXI_RVALID <= '0';
            end if;
       end if;
   end if;
end process proc_read_data;

--READ ENABLE--
    --Ha van olvas�si c�m, akkor lehet olvasni
r_en <= r_addr_valid;

----SPI----

--SPI--VEZ�RLO
    --A c�meket �gy kezelem hogy a felso 16 bitet haszn�lom a "spi_send_data"-ban mint c�met, az als� 16 az SPI eszk�zv�laszt�nak haszn�lhat�(ez a bitsz�m v�ltoztathat� a "DEVICES" �ltal) 
proc_spi : process (S_AXI_ACLK)
    begin
   if(rising_edge(S_AXI_ACLK)) then
       if(S_AXI_ARESETN = '1') then
            spi_en <= '0';
       else
       
            --SPI enged�lyez�s--
            if((w_en = '1' or r_en = '1') and spi_busy = '0') then --ha lehet �rni vagy olvasni �s nem foglalt az SPI, akkor jelezz�k az SPI-nak a kommunik�ci�t, ez egy �rajelig tart� pulzus
                spi_en <= '1';
            else
                spi_en <= '0';
            end if;
            
            --�R�S--
                --(ha egyszerre van �r�s �s olvas�s akkor valamelyik a domin�l, �n az �r�st v�lasztottam; ez�rt nem jelenik meg a felt�telben, hogy ne legyen �r�s)
            if(w_en = '1' and spi_busy = '0') then
                --SPI k�ld�si adatvonal
                spi_send_data <= w_data(SPI_DATA_WIDTH-1 downto 0);
            end if;
            
            --OLVAS�S--
                --(ha egyszerre van �r�s �s olvas�s, akkor az �r�s domin�l; ez�rt jelenik meg a felt�telben az, hogy ne legyen �r�s)
            if(r_en = '1' and w_en = '0' and spi_busy = '0') then
            spi_send_data <= (15 downto 0 => '0')&r_data(31 downto 24);
--                 spi_send_data <= r_addr(31 downto 24); 
					  --elso 8 bit: mem�ria parancs -- m�sodik 8 bit: c�m -- harmadik 8 bit: data(ez itt nulla)
                    --(Megj.: a "r_addr(15 downto 8)" -nak tartalmaznia kell a megfelelo opcode-ot, ez el�g ronda �gy :( )
      
            end if;
            
       end if;
   end if;
end process proc_spi;

end behavioral;