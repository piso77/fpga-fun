library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dualedge is
	port(
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		level : in  STD_LOGIC;
		tick : out  STD_LOGIC
	);
end dualedge;

architecture moore of dualedge is
	type state_type is (zero, edger, one, edgef);
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
				state_next <= edger;
			end if;
		when edger =>
			if level='0' then
				state_next <= zero;
			else -- level='1'
				state_next <= one;
			end if;
		when one =>
			if level='0' then
				state_next <= edgef;
			end if;
		when edgef =>
			tick <= '1';
			if level='0' then
				state_next <= zero;
			else -- level='1'
				state_next <= one;
			end if;
	end case;
end process;

end moore;