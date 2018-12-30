library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity edge_detector is
	port(
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		level : in  STD_LOGIC;
		tick : out  STD_LOGIC
	);
end edge_detector;

architecture moore of edge_detector is
	type state_type is (zero, edge, one);
	signal state_reg, state_next: state_type;
begin

process(clk, rst)
begin
	if (rst='1') then
		state_reg <= zero;
	elsif rising_edge(clk) then
		state_reg <= state_next;
	end if;
end process;

process(state_reg, level)
begin
	state_next <= state_reg;
	tick <= '0';
	case state_reg is
		when zero =>
			if level='1' then
				state_next <= edge;
			end if;
		when edge =>
			tick <= '1';
			if level='0' then
				state_next <= zero;
			else -- level='1'
				state_next <= one;
			end if;
		when one =>
			if level='0' then
				state_next <= zero;
			end if;
	end case;
end process;

end moore;

architecture mealy of edge_detector is
	type state_type is (zero, one);
	signal state_reg, state_next: state_type;
begin

process(clk, rst)
begin
	if (rst='1') then
		state_reg <= zero;
	elsif rising_edge(clk) then
		state_reg <= state_next;
	end if;
end process;

process(state_reg, level)
begin
	tick <= '0';
	state_next <= state_reg;
	case state_reg is
		when zero =>
			if level='1' then
				tick <= '1';
				state_next <= one;
			end if;
		when one =>
			if level='0' then
				state_next <= zero;
			end if;
	end case;
end process;

end mealy;

architecture gate_level of edge_detector is
	signal state: std_logic;
begin
process(clk, rst)
begin
	if rst='1' then
		state <= '0';
	elsif rising_edge(clk) then
		state <= level;
	end if;
end process;

tick <= level and not state;

end gate_level;