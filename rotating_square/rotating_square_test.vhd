library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rotating_square_test is
	port(
		clk : in  STD_LOGIC;
		switch : in  STD_LOGIC_VECTOR(1 downto 0);
		an : out  STD_LOGIC_VECTOR (3 downto 0);
		sseg : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end rotating_square_test;

architecture arch of rotating_square_test is
	signal dig0, dig1, dig2, dig3: std_logic_vector(7 downto 0);
begin

rs: entity work.rotating_square(arch)
	port map(
		clk => clk,
		en => switch(0),
		cw => switch(1),
		out0 => dig0,
		out1 => dig1,
		out2 => dig2,
		out3 => dig3
	);

dm: entity work.disp_mux(arch)
	port map(
		clk => clk,
		reset => '0',
		in0 => dig0,
		in1 => dig1,
		in2 => dig2,
		in3 => dig3,
		an => an,
		sseg => sseg
	);

end arch;