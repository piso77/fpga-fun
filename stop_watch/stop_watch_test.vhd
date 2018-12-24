library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity stop_watch_test is
   port(
		clk : in  STD_LOGIC;
		switch : in  STD_LOGIC_VECTOR (1 downto 0);
		an : out  STD_LOGIC_VECTOR (3 downto 0);
		sseg : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end stop_watch_test;

architecture arch of stop_watch_test is
	signal dig0, dig1, dig2: STD_LOGIC_VECTOR (3 downto 0);
begin

	sw: entity work.stop_watch(cascade_arch)
	port map(
		clk => clk,
		go => switch(1),
		clr => switch(0),
		d0 => dig0,
		d1 => dig1,
		d2 => dig2
	);

	hex_mux: entity work.disp_hex_mux(arch)
   port map (
		clk => clk,
		reset => '0',
		hex0 => "0000",
		hex1 => dig2,
		hex2 => dig1,
		hex3 => dig0,
		dp_in => "1011",
		an => an,
		sseg => sseg
	);

end arch;

