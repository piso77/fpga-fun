library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reaction_top is
	Port(
		clk : in  STD_LOGIC;
      switch : in  STD_LOGIC_VECTOR (2 downto 0);
		led : out  STD_LOGIC_VECTOR (2 downto 0);
		an : out  STD_LOGIC_VECTOR (3 downto 0);
		sseg : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end reaction_top;

architecture arch of reaction_top is
	signal clr, star, stp: std_logic;
	signal delay : std_logic_vector(15 downto 0);
begin

	clr <= not switch(0);
	star <= not switch(1);
	stp <= not switch(2);

	Inst_reaction: entity work.reaction(arch)
	PORT MAP(
		clk => clk,
		clear => clr,
		start => star,
		stop => stp,
		error => led(1),
		ready => led(0),
		led => led(2),
		delay => delay
	);

	Inst_disp_hex_mux: entity work.disp_hex_mux(arch)
	PORT MAP(
		clk => clk,
		reset => clr,
		hex0 => delay(15 downto 12),
		hex1 => delay(11 downto 8),
		hex2 => delay(7 downto 4),
		hex3 => delay(3 downto 0),
		dp_in => "1111",
		an => an,
		sseg => sseg
	);
end arch;

