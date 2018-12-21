----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:41:01 12/20/2018 
-- Design Name: 
-- Module Name:    shift_reg - arch 
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

entity shift_reg is
	generic(WIDTH : integer := 8);
	port(
		clk : in  STD_LOGIC;
		reset : in  STD_LOGIC;
		load : in  STD_LOGIC;
		dir : in  STD_LOGIC_VECTOR (1 downto 0);
		input : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		output : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0)
	);
end shift_reg;

architecture arch of shift_reg is
	signal r_reg, r_next: STD_LOGIC_VECTOR(WIDTH-1 downto 0);
	signal tmp: STD_LOGIC_VECTOR(2 downto 0);
begin

process(clk, reset)
begin
	if (reset = '1') then
		r_reg <= (others => '0');
	elsif (rising_edge(clk)) then
		r_reg <= r_next;
	end if;
end process;

-- next-state logic
tmp <= not load & not dir;
with tmp select
	r_next <=
	input														when "100", -- load / latch
	r_reg(WIDTH-2 downto 0) & input(0) 				when "010", -- shift left
	input(WIDTH-1) & r_reg(WIDTH-1 downto 1) 		when "001", -- shift right
	r_reg 													when others; 

-- output logic
output <= r_reg;
end arch;