----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:59:08 12/20/2018 
-- Design Name: 
-- Module Name:    d_ff_test - arch 
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

entity d_ff_test is
	generic(N: integer := 8);
	port(
		clk : in  STD_LOGIC;
		joy_left: in STD_LOGIC;
		joy_right: in STD_LOGIC;
		switch : in  STD_LOGIC_VECTOR(N-1 downto 0);
		led : out  STD_LOGIC_VECTOR(N-1 downto 0)
	);
end d_ff_test;

architecture arch of d_ff_test is
	signal enable, reset: STD_LOGIC;
begin

reset <= not joy_left;
enable <= not joy_right;

ff: entity work.d_ff(merge_arch)
	generic map(N => N)
	port map(
		clk => clk,
		reset => reset,
		en => enable,
		d => switch,
		q => led
	);

end arch;

