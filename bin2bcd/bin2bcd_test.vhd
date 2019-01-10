library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bin2bcd_test is
    Port ( clk : in  STD_LOGIC;
           switch : in  STD_LOGIC_VECTOR(1 downto 0);
           --switch : in  STD_LOGIC_VECTOR (7 downto 0);
           an : out  STD_LOGIC_VECTOR (3 downto 0);
           sseg : out  STD_LOGIC_VECTOR (7 downto 0));
end bin2bcd_test;

architecture arch of bin2bcd_test is
	signal start, reset : std_logic;
	signal bcd0, bcd1, bcd2, bcd3 : std_logic_vector(3 downto 0);
begin

start <= switch(0);
reset <= switch(1);

bin: entity work.bin2bcd(arch)
	port map(
		clk => clk,
		reset => reset,
		start => start,
		bin => "1000000000000",
		ready => open,
		done_tick => open,
		bcd0 => bcd0,
		bcd1 => bcd1,
		bcd2 => bcd2,
		bcd3 => bcd3
	);

disp: entity work.disp_hex_mux(arch)
	port map(
		clk => clk,
		reset => reset,
		hex3 => bcd0,
		hex2 => bcd1,
		hex1 => bcd2,
		hex0 => bcd3,
		dp_in => "1111",
		an => an,
		sseg => sseg
	);

end arch;