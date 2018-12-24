library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity disp_hex_mux_test is
	port(
		clk : in  STD_LOGIC;
		switch : in  STD_LOGIC_VECTOR (7 downto 0);
		an : out  STD_LOGIC_VECTOR (3 downto 0);
		sseg : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end disp_hex_mux_test;

architecture arch of disp_hex_mux_test is
	signal a,b: unsigned(7 downto 0);
	signal sum: std_logic_vector(7 downto 0);
begin

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