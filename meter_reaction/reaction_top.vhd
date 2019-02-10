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
	signal delay : std_logic_vector(12 downto 0);
	signal t0, t1, t2, t3 : std_logic_vector(3 downto 0);
	signal h0, h1, h2, h3 : std_logic_vector(3 downto 0);
	signal done_tick: std_logic;
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
		done_tick => done_tick,
		delay => delay
	);

	led(1) <= error;

	Inst_bin2bcd: entity work.bin2bcd(arch) PORT MAP(
		clk => clk,
		reset => clr,
		start => done_tick,
		bin => delay,
		ready => open,
		done_tick => open,
		bcd3 => t3,
		bcd2 => t2,
		bcd1 => t1,
		bcd0 => t0
	);

	h3 <= t3 when delay/="1111111111111" else "1001";
	h2 <= t2 when delay/="1111111111111" else "1001";
	h1 <= t1 when delay/="1111111111111" else "1001";
	h0 <= t0 when delay/="1111111111111" else "1001";

	Inst_disp_hex_mux: entity work.disp_hex_mux(arch)
	PORT MAP(
		clk => clk,
		reset => clr,
		hex0 => h3,
		hex1 => h2,
		hex2 => h1,
		hex3 => h0,
		dp_in => "1111",
		an => an,
		sseg => sseg
	);
end arch;