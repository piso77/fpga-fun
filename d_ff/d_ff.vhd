----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:28:19 12/20/2018 
-- Design Name: 
-- Module Name:    d_ff - arch 
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
use IEEE.NUMERIC_STD.ALL;

entity d_ff is
	generic(N: integer := 1);
   port(
		 clk : in  STD_LOGIC;
		 reset : in STD_LOGIC;
		 en : in  STD_LOGIC;
		 d : in  STD_LOGIC_VECTOR(N-1 downto 0);
		 q : out  STD_LOGIC_VECTOR(N-1 downto 0)
	);
end d_ff;

architecture merge_arch of d_ff is
begin

process(reset, clk)
begin
	if (reset = '1') then
		q <= (others => '0');
	elsif (rising_edge(clk)) then
		if (en = '1') then
			q <= d;
		end if;
	end if;
end process;

end merge_arch;

architecture multi_seg_arch of d_ff is
	signal r_next, r_reg : STD_LOGIC_vector(N-1 downto 0);
begin

-- D FF
process(reset, clk)
begin
	if (reset = '1') then
		r_reg <= (others => '0');
	elsif (rising_edge(clk)) then
		r_reg <= r_next;
	end if;
end process;

-- next-state logic
r_next <= d when en = '1' else r_reg;

-- output
q <= r_reg;
end multi_seg_arch;