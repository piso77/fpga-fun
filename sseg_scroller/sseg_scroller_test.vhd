library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sseg_scroller_test is
    Port ( clk : in  STD_LOGIC;
           switch : in  STD_LOGIC_VECTOR (1 downto 0);
           an : out  STD_LOGIC_VECTOR (3 downto 0);
           sseg : out  STD_LOGIC_VECTOR (7 downto 0));
end sseg_scroller_test;

architecture arch of sseg_scroller_test is
	signal d0, d1, d2, d3: std_logic_vector(3 downto 0);
begin

ss: entity work.sseg_scroller(arch)
	port map(
		clk => clk,
		en => switch(0),
		dir => switch(1),
		d0 => d0,
		d1 => d1,
		d2 => d2,
		d3 => d3
	);

dhm: entity work.disp_hex_mux(arch)
	port map(
		clk => clk,
		reset => '0',
		hex0 => d0,
		hex1 => d1,
		hex2 => d2,
		hex3 => d3,
		dp_in => "1111",
		an => an,
		sseg => sseg
	);

end arch;

