library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity debounce_test is
	port(
		clk : in  STD_LOGIC;
		btn : in  STD_LOGIC_VECTOR (1 downto 0);
		an : out  STD_LOGIC_VECTOR (3 downto 0);
		sseg : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end debounce_test;

architecture arch of debounce_test is
	signal q0_reg, q0_next: unsigned(7 downto 0);
	signal q1_reg, q1_next: unsigned(7 downto 0);
	signal b_count, d_count: std_logic_vector(7 downto 0);
	signal clr, db, edv, edb: std_logic;
begin

hexmux: entity work.disp_hex_mux(arch)
	port map(
		clk => clk,
		reset => '0',
		hex3 => b_count(7 downto 4),
		hex2 => b_count(3 downto 0),
		hex1 => d_count(7 downto 4),
		hex0 => d_count(3 downto 0),
		dp_in => "1011",
		an => an,
		sseg => sseg
	);

deb: entity work.debounce(arch)
	port map(
		clk => clk,
		rst => '0',
		sw => btn(1),
		db => db	
	);

edva: entity work.edge_detector(gate_level)
	port map(
		clk => clk,
		rst => '0',
		level => btn(1),
		tick => edv
	);

eddb: entity work.edge_detector(gate_level)
	port map(
		clk => clk,
		rst => '0',
		level => db,
		tick => edb
	);

clr <= btn(0);
process(clk)
begin
	if rising_edge(clk) then
		q0_reg <= q0_next;
		q1_reg <= q1_next;
	end if;
end process;

q1_next <= (others => '0') when clr='1' else
			  q1_reg + 1 when edb='1' else
			  q1_reg;
q0_next <= (others => '0') when clr='1' else
			  q0_reg + 1 when edv='1' else
			  q0_reg;

b_count <= std_logic_vector(q0_reg);
d_count <= std_logic_vector(q1_reg);
end arch;