----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:18:52 12/17/2018 
-- Design Name: 
-- Module Name:    test - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test is
	generic(WIDTH: integer := 8);
	port(
		clk: in std_logic;
		switch : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		joy : in STD_LOGIC_VECTOR(4 downto 0);
		led : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		an: out STD_LOGIC_VECTOR (3 downto 0);
		sseg: out STD_LOGIC_VECTOR (7 downto 0)
	);
end test;

architecture arch of test is
	constant JOYS: integer := 5; -- joy btns
	signal a,b: unsigned(7 downto 0);
	signal sum: std_logic_vector(7 downto 0);
begin

assert (WIDTH >= JOYS+3) report "WIDTH too small: minimum " & integer'image(JOYS) severity failure;

for_loop_joy:
for i in 0 to JOYS-1 generate
	with switch(i) select
		led(i) <=
		switch(i) when '1',
		not joy(i) when others;
end generate;

for_loop_switch:
for i in JOYS to (WIDTH-1) generate
	led(i) <= switch(i);
end generate;

ff: entity work.disp_hex_mux(arch)
port map(
	clk => clk,
	reset => '0',
	hex0 => switch(3 downto 0),
	hex1 => switch(7 downto 4),
	hex2 => sum(7 downto 4),
	hex3 => sum(3 downto 0),
	dp_in => "1101",
	an => an,
	sseg => sseg
);

a <= unsigned("0000" & switch(7 downto 4));
b <= unsigned("0000" & switch(3 downto 0));
sum <= std_logic_vector(a + b);

end arch;