---------------It converts 50MHZ which is inbulit on CPLD Krypton board to required f for sunchronization ---------------
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Clk_sync is
   generic
	(
		f	: integer := 50
	);
	
	port (inclk : in std_logic;
			outclk : out std_logic);
end entity;
architecture behave of Clk_sync is
	signal count : unsigned(15 downto 0) := to_unsigned(0,16);
	constant start : unsigned(15 downto 0) := to_unsigned(0,16);
	constant half : unsigned(15 downto 0) := to_unsigned(f,16);
	constant full : unsigned(15 downto 0) := to_unsigned(2*f,16);

	signal outsig : std_logic := '0';
	
begin
process(inclk)
begin
	if rising_edge(inclk) then
		count <= count + 1;
		
		if (count < half) then
			outsig <= '0';
		else
			outsig <= '1';
		end if;
		
		if (count = full) then
			count <= start;
		end if;
		
		outclk <= outsig;
	end if;
end process;

end behave;