library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce_test is
	port(
		clk : in  STD_LOGIC;
		btn : in  STD_LOGIC_VECTOR (1 downto 0);
		an : out  STD_LOGIC_VECTOR (3 downto 0);
		sseg : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end debounce_test;

--architecture chu of debounce_test is
--	signal q1_reg, q1_next: unsigned(7 downto 0);
--	signal q0_reg, q0_next: unsigned(7 downto 0);
--	signal b_count, d_count: std_logic_vector(7 downto 0);
--	signal btn_reg, db_reg: std_logic;
--	signal db_level, db_tick: std_logic;
--	signal btn_tick, clr: std_logic;
--	signal reset, click: std_logic;
--begin
--
--	reset <= not btn(0);
--	click <= not btn(1);
--	
--	disp_unit: entity work.disp_hex_mux(arch)
--		port map(
--			clk => clk,
--			reset => '0',
--			hex3 => b_count(7 downto 4),
--			hex2 => b_count(3 downto 0),
--			hex1 => d_count(7 downto 4),
--			hex0 => d_count(3 downto 0),
--			dp_in => "1011",
--			an => an,
--			sseg => sseg
--		);
--		
--	db_unit: entity work.debounce(arch)
--		port map(
--			clk => clk,
--			rst => '0',
--			sw => click,
--			db => db_level
--		);
--	
--	process(clk)
--	begin
--		if rising_edge(clk) then
--			btn_reg <= click;
--			db_reg <= db_level;
--		end if;
--	end process;
--	btn_tick <= (not btn_reg) and click;
--	db_tick <= (not db_reg) and db_level;
--	
--	clr <= reset;
--	process(clk)
--	begin
--		if rising_edge(clk) then
--			q1_reg <= q1_next;
--			q0_reg <= q0_next;
--		end if;
--	end process;
--	q1_next <= (others => '0') when clr='1' else
--				  q1_reg + 1 when btn_tick='1' else
--				  q1_reg;
--	q0_next <= (others => '0') when clr='1' else
--				  q0_reg + 1 when db_tick='1' else
--				  q0_reg;
--	
--	b_count <= std_logic_vector(q1_reg);
--	d_count <= std_logic_vector(q0_reg);
--end chu;

architecture arch of debounce_test is
	signal b_reg, b_next: unsigned(7 downto 0);
	signal d_reg, d_next: unsigned(7 downto 0);
	signal b_count, d_count: std_logic_vector(7 downto 0);
	signal clr, debounced, edgeraw, edgedeb: std_logic;
	signal click, reset: std_logic;
begin

reset <= not btn(0);
click <= not btn(1);

display_hex_mux: entity work.disp_hex_mux(arch)
	port map(
		clk => clk,
		reset => '0',
		hex0 => b_count(7 downto 4),
		hex1 => b_count(3 downto 0),
		hex2 => d_count(7 downto 4),
		hex3 => d_count(3 downto 0),
		dp_in => "1101",
		an => an,
		sseg => sseg
	);

-- raw input
edge_detector_vanilla: entity work.edge_detector(gate_level)
	port map(
		clk => clk,
		rst => '0',
		level => click,
		tick => edgeraw
	);

-- debounced input
debouncer: entity work.debounce(upfront)
	port map(
		clk => clk,
		rst => '0',
		sw => click,
		db => debounced
	);

edge_detector_debounced: entity work.edge_detector(gate_level)
	port map(
		clk => clk,
		rst => '0',
		level => debounced,
		tick => edgedeb
	);

clr <= reset;
process(clk)
begin
	if rising_edge(clk) then
		b_reg <= b_next;
		d_reg <= d_next;
	end if;
end process;

b_next <= (others => '0') when clr='1' else
			  b_reg + 1 when edgeraw='1' else
			  b_reg;
d_next <= (others => '0') when clr='1' else
			  d_reg + 1 when edgedeb='1' else
			  d_reg;

b_count <= std_logic_vector(b_reg);
d_count <= std_logic_vector(d_reg);
end arch;