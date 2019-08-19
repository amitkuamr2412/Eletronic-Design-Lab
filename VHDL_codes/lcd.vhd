------------------# To control the LCD module display #-------------------
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd is
   generic
	(
		num_bits_rcv	: integer := 128  --Data size in number of bits
	);
	
port ( 
       clk: in std_logic;                          --clock i/p
--	    cnt: in std_logic_vector(7 downto 0);      --BER
		 Rcv_data1 : in std_logic_vector((num_bits_rcv-1) downto 0);
		 Rcv_data2 : in std_logic_vector((num_bits_rcv-1) downto 0);
       lcd_rw : out std_logic;                         --read & write control
       lcd_e : out std_logic;                         --enable control
       lcd_rs : out std_logic;                         --data or command control
       data  : out std_logic_vector(7 downto 0));     --data line
end lcd;

architecture Behavioral of lcd is

  constant N: integer :=42;      --Number of characters + 5*2      29 (5 + 16 + 5 + 3)  

  type arr is array (1 to N) of std_logic_vector(7 downto 0);
  signal print_data : arr :=    (X"38",X"0c",X"06",X"01",X"80",X"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",X"38",X"0c",X"06",X"00",X"C0",X"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00"); --command and data to display LEFT  ,X"38",X"0c",X"06",X"01",X"C0",X"00",X"00",X"00"                                       


--38 = Function Set: 8-bit, 2 Line, 5x7 Dots
--0c = Display on Cursor off
--06 = Entry Mode
--01= Clear Display
--C0 = Place Curser to 2nd line
    
--signal count,d1,d2,d3 : integer ;
begin

--print_data(127 downto 88) <= "0011100000001100000001100000000111000000" ;            --starting bits N-14 for 29
    L1: for item in 0 to 15 generate
      print_data(item+6)(7 downto 0)   <=  Rcv_data1( ((num_bits_rcv-1)-8*item) downto ((num_bits_rcv-8)-8*item) ) ;
    end generate L1;
	 
	     L2: for item in 0 to 15 generate
      print_data(item+27)(7 downto 0)   <=  Rcv_data2( ((num_bits_rcv-1)-8*item) downto ((num_bits_rcv-8)-8*item) ) ;
    end generate L2;
--------------------------------------------------------------------------------------------------   
--	count <= to_integer(unsigned(cnt)) ;
--	d1 <= (count mod 10) ;
--	d2 <= (count mod 100) ;
--	d3 <= (count mod 1000) ;
--   d1 := 0 ;
--   d2 := 0 ;
--   d3 := 0 ;	
--	print_data(27)(7 downto 0) <= std_logic_vector(to_unsigned(d1,8));
--	print_data(28)(7 downto 0) <= std_logic_vector(to_unsigned(d2,8));
--	print_data(29)(7 downto 0) <= std_logic_vector(to_unsigned(d3,8));	 
--------------------------------------------------------------------------------------------------------------

    lcd_rw <= '0';  --lcd write

process(clk)
  variable i : integer := 0;   --i controls clock Now 50Meg/20Meg
  variable j : integer := 1;   -- j controls array 

begin
 if clk'event and clk = '1' then
   if i <= 1000000 then
     i := i + 1;
     lcd_e <= '1';
     data <= print_data(j)(7 downto 0);

   elsif i > 1000000 and i < 2000000 then
     i := i + 1;
     lcd_e <= '0';
 
   elsif i = 2000000 then
      j := j + 1;
      i := 0;
  end if;

  if (j <= 5 or (j >= 22 and j <= 26) ) then
    lcd_rs <= '0';    --command signal
 -- elsif ( j > 5 or    then
 else 
    lcd_rs <= '1';   --data signal
  end if;

  if j = N+1 then  --repeated display of data
    j := 5;
   end if;
end if;

end process;

end Behavioral;
