library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity period_counter_test is
	generic(WIDTH: integer := 16);
	port(
		clk : in  STD_LOGIC;
		switch : in  STD_LOGIC_VECTOR (2 downto 0);
		led : out  STD_LOGIC_VECTOR (1 downto 0);
		an : out  STD_LOGIC_VECTOR (3 downto 0);
		sseg : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end period_counter_test;

architecture arch of period_counter_test is
	signal tmp: std_logic_vector(WIDTH-1 downto 0);
begin

	pcount: entity work.period_counter(arch)
		generic map(W => WIDTH)
		port map(
			clk => clk,
			reset => switch(0),
			start => switch(1),
			si => switch(2),
			ready => led(0),
			done_tick => led(1),
			prd => tmp
		);

	disphex: entity work.disp_hex_mux(arch)
		port map(
			clk => clk,
			reset => '0',
			dp_in => "1111",
			an => an,
			sseg => sseg,
			hex0 => tmp(15 downto 12),
			hex1 => tmp(11 downto 8),
			hex2 => tmp(7 downto 4),
			hex3 => tmp(3 downto 0)
		);

end arch;

