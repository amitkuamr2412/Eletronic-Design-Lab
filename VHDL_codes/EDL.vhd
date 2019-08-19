---------------It converts 50MHZ which is inbulit on CPLD Krypton board to 1KHz ---------------
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EDL is
   generic
	(
		num_bits	: integer :=  129  --Data size in number of bits
	);
	port (
	      Tx_data : out std_logic ;
			Rx_data : in std_logic;
		--	Rx_lcd : out std_logic_vector((num_bits-1)downto 0);
		 --  ber : out std_logic_vector(7 downto 0);
			lcd_rw : out std_logic;                         --read & write control
         lcd_e : out std_logic;                         --enable control
         lcd_rs : out std_logic;                         --data or command control
			data  : out std_logic_vector(7 downto 0);     --data line
			input  : in std_logic_vector(6 downto 0);
			clk : in std_logic ;
			lcd_high: out std_logic;
			lcd_low: out std_logic ;
			rst: in std_logic
			);
end entity;

architecture behave of EDL is
------------------------------------------------------------------
 component lcd is
   generic
	(
		num_bits_rcv	: integer := 128  --Data size in number of bits
	); 
port ( 
       clk: in std_logic;                          --clock i/p
  --     cnt: in std_logic_vector(7 downto 0);      --BER
		 Rcv_data1 : in std_logic_vector((num_bits_rcv-1) downto 0);
		 Rcv_data2 : in std_logic_vector((num_bits_rcv-1) downto 0);
       lcd_rw : out std_logic;                         --read & write control
       lcd_e : out std_logic;                         --enable control
       lcd_rs : out std_logic;                         --data or command control
       data  : out std_logic_vector(7 downto 0));     --data line
end component lcd;
-------------------------------------------------------------------------
  component Clk_sync is
	port (inclk : in std_logic;
			outclk : out std_logic);		
  end component;
   -------------------------------------------------------------------------
component Rx_clk is	
	port (inclk : in std_logic;
	      en : in std_logic ;
			outclk : out std_logic);
end component;
------------------------------------------------------------------------
   function f_log2 (x : positive) return natural is
      variable i : natural;
   begin
      i := 0;  
      while (2**i < x) and i < 31 loop
         i := i + 1;
      end loop;
      return i;
   end function;
--------------------------------------------------------------------------
	signal rcv_clk : std_logic ;
	signal en: std_logic := '0' ;
	signal process_clk : std_logic ;
	signal Tx_sig : std_logic_vector((num_bits-1) downto 0);
	signal temp : std_logic_vector(127 downto 0);
	signal Rx_sig : std_logic_vector((num_bits-1)downto 0);
	signal text_data : std_logic_vector((num_bits-1)downto 0);
   signal i     : unsigned(f_log2(num_bits) downto 0) := to_unsigned(0,(f_log2(num_bits) + 1));
	signal j     : unsigned(f_log2(num_bits) downto 0) := to_unsigned(0,(f_log2(num_bits) + 1));
-- signal count : unsigned(f_log2(num_bits) downto 0) := to_unsigned(0,(f_log2(num_bits) + 1));
   signal count :unsigned(7 downto 0) := to_unsigned(0,8) ;
	signal cnt : std_logic_vector(7 downto 0);
   signal rst_bar: std_logic ;
	----------------------------------Data_bits--------------------------------------------------------
	signal hello_what_up : std_logic_vector((num_bits-1)downto 0) := "101001000011001010110110001101100011011110010000001110111011010000110000101110100011100110010011101110101011100000010000000100001";
	signal hello_world : std_logic_vector((num_bits-1)downto 0) := "101001000011001010110110001101100011011110010000001010111011011110111001001101100011001000010000000100000001000000010000000100000";
   signal fine_thankyou: std_logic_vector((num_bits-1)downto 0) := "101000110011010010110111001100101001000000101010001101000011000010110111001101011011110010110111101110101001000000010000000100000";
   signal how_r_u: std_logic_vector((num_bits-1)downto 0) := "101001000011011110111011100100000011000010111001001100101001000000111100101101111011101010011111100100000001000000010000000100000";
   signal thank: std_logic_vector((num_bits-1)downto 0) := "101010100011010000110000101101110011010110010000001011001011011110111010100100000001110100010100100100000001000000010000000100000";
   signal working: std_logic_vector((num_bits-1)downto 0) := "101001001011101000010000001101001011100110010000001110111011011110111001001101011011010010110111001100111001000000010000100100001";
   signal group_edl: std_logic_vector((num_bits-1)downto 0) := "101000101010001000100110000100000010001110111001001101111011101010111000000100000010001000100010000110000001101010010000000100000";
   signal name: std_logic_vector((num_bits-1)downto 0) := "101000001011011010110100101110100001000000100010001101000011100100111010101110110001000000100111001101001011011000110010101110011";
   signal Datarate: std_logic_vector((num_bits-1)downto 0) := "101000100011000010111010001100001011100100110000101110100011001010010000000110001001000000100110101000010010100000101001100100000";


	
begin
	  
	  rst_bar   <= not(rst) ;
	  
Clock_frequency: Clk_sync port map (inclk =>clk , outclk =>process_clk);
Received_frequency: Rx_clk port map (inclk =>clk , outclk =>rcv_clk, en => en);

   process(process_clk,rst_bar,i,j,Rx_data,rcv_clk,input)
 	 begin	
	----------------Trigger receiver clock------------------------------------------ 
	 	if rising_edge(Rx_data) then
		en <= '1' ;
		end if ;
	-----------------Select Data--------------------------------
    if rising_edge(process_clk) then
	     if (input(0) = '1') then
		  text_data <= working;
		  elsif (input(1) = '1') then
		  text_data <= Datarate ;
		   elsif (input(2) = '1') then
			text_data <= hello_what_up;
			 elsif (input(3) = '1') then
			 text_data <= how_r_u ;
			  elsif (input(4) = '1') then
			  text_data <= fine_thankyou ;
			   elsif (input(5) = '1') then
				text_data <= group_edl;
				 elsif (input(6) = '1') then
				 text_data <= name;
--				  elsif (input(7) = '1') then
--				  text_data <= thank;
				  else
				   
					      text_data <= hello_world ;    
		end if ;
		        
---------------------Transmitter-------------------------------------------------	 
        if (rst_bar = '1') then
            Tx_sig <= (others => '0');
				Tx_data <= '0' ;
				i <= (others => '0');
	     else 			
            
	         if (i /= num_bits) then
             Tx_data <=  text_data(to_integer(i)) ;
			    Tx_sig(to_integer(i))<=  text_data(to_integer(i)) ;
			    i <= i + 1;
		      else 
			    i <= to_unsigned(num_bits, i'length);
				 -- i <= (others => '0');
              Tx_data <= '0' ;
		     end if;
			  
		end if ;
			  		  
	end if ;
-----------------Reciever------------------------------------------------		  
    	if falling_edge(rcv_clk) then
		   if (rst_bar = '1') then
			   Rx_sig <= (others => '0');
				j <= (others => '0');
			 else 
			     if (j /= num_bits) then
			      Rx_sig(to_integer(j))<=  Rx_data ;
			      j <= j + 1;
		        else 
			      j <= to_unsigned(num_bits, j'length);
		        end if;
				  
			   end if ;	  
		  
		   end if ;
---------------------------------------------------------------------		
--      L2: for it in 0 to num_bits-1 loop
--      if ( Tx_sig(it) /= Rx_sig(it) ) then 
--		count <= count + 1 ;
--		end if ;
--      end loop L2;
--------------------------------------------------------------------

				
end process;
-------------------------------------------------------------------
       lcd_high <= '1' ;
		 lcd_low <= '0' ;		
		
--      if ( Tx_sig(0) /= Rx_sig(0) ) then 
--		count <= count + 1 ;
--		end if ;
 temp(127) <='0' ; --Rx_sig(num_bits-2 downto 0)
 temp(126 downto 0) <= Rx_sig(num_bits-1 downto 2) ; 	
--      ber <= std_logic_vector(count);
--		cnt <= std_logic_vector(count);
		lcd_type : lcd port map (clk => clk ,lcd_rw =>lcd_rw ,lcd_e => lcd_e, lcd_rs=> lcd_rs, data => data , Rcv_data1 => Rx_sig(num_bits-2 downto 0) ,Rcv_data2 => Rx_sig(num_bits-1 downto 1)) ;
		

end behave;