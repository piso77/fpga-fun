----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:44:19 12/18/2018 
-- Design Name: 
-- Module Name:    add_w_carry_top - Behavioral 
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

entity add_w_carry_top is
	port(
		switch : in  STD_LOGIC_VECTOR (7 downto 0);
		led : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end add_w_carry_top;

architecture Behavioral of add_w_carry_top is
begin
adder: entity work.add_w_carry(arch)
		 generic map(N => 4)
		 port map(
			a => switch(3 downto 0),
			b => switch(7 downto 4),
			sum => led(3 downto 0),
			cout => led(7)
		 );
end Behavioral;

