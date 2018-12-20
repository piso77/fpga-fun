----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:54:33 12/19/2018 
-- Design Name: 
-- Module Name:    barrell_shifter - sel_arch 
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

entity barrell_shifter is
   port(
		a : in  STD_LOGIC_VECTOR (7 downto 0);
      amt : in  STD_LOGIC_VECTOR (2 downto 0);
      y : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end barrell_shifter;

architecture sel_arch of barrell_shifter is
begin
	with amt select
		y <= a 									  when "000",
			  a(0)          & a(7 downto 1) when "001",
			  a(1 downto 0) & a(7 downto 2) when "010",
			  a(2 downto 0) & a(7 downto 3) when "011",
			  a(3 downto 0) & a(7 downto 4) when "100",
			  a(4 downto 0) & a(7 downto 5) when "101",
			  a(5 downto 0) & a(7 downto 6) when "110",
			  a(6 downto 0) & a(7) when others; -- "111"

end sel_arch;

architecture multi_stage_arch of barrell_shifter is
	signal s0, s1: std_logic_vector(7 downto 0);
begin
	-- stage 0: shift 0 or 1 bit
	s0 <= a(0) & a(7 downto 1) when amt(0) = '1' else a;
	-- stage 1: shift 0 or 2 bits of s0
	s1 <= s0(1 downto 0) & s0(7 downto 2) when amt(1) = '1' else s0; 
	-- stage 2: shift 0 or 4 bits of s1
	y <= s1(3 downto 0) & s1(7 downto 4) when amt(2) = '1' else s1;
end multi_stage_arch;