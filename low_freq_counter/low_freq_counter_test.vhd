library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity low_freq_counter_test is
    Port ( clk : in  STD_LOGIC;
           switch : in STD_LOGIC_VECTOR (2 downto 0);
           an : out  STD_LOGIC_VECTOR (3 downto 0);
           sseg : out  STD_LOGIC_VECTOR (7 downto 0));
end low_freq_counter_test;

architecture arch of low_freq_counter_test is
	signal hex0, hex1, hex2, hex3: std_logic_vector(3 downto 0);
begin

	lowfreqcnt: entity work.low_freq_counter(arch)
	port map(
		clk => clk,
		reset => switch(0),
		start => switch(1),
		si => switch(2),
		bcd3 => hex3,
		bcd2 => hex2,
		bcd1 => hex1,
		bcd0 => hex0
	);
	
	disphex: entity work.disp_hex_mux(arch)
	port map(
		clk => clk,
		reset => switch(0),
		hex0 => hex0,
		hex1 => hex1,
		hex2 => hex2,
		hex3 => hex3,
		dp_in => "1111",
		an => an,
		sseg => sseg
	);
end arch;

