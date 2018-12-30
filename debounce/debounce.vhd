library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce is
	port(
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		sw : in  STD_LOGIC;
		db : out  STD_LOGIC
	);
end debounce;

architecture arch of debounce is
	constant N: integer := 24; -- 2^N * 10ns = 10ms tick -- 100Mhz clk
	signal cnt_reg, cnt_next: unsigned(N-1 downto 0);
	signal tick: std_logic;
	type state_type is (zero, wait1_1, wait1_2, wait1_3, one, wait0_1, wait0_2, wait0_3);
	signal state_reg, state_next: state_type;
begin

process(clk, rst)
begin
	if rst='0'then
		cnt_reg <= (others => '0');
		state_reg <= zero;
	elsif rising_edge(clk) then
		cnt_reg <= cnt_next;
		state_reg <= state_next;
	end if;
end process;

cnt_next <= cnt_reg+1;
tick <= '1' when cnt_reg = 0 else '0';

process(state_reg, sw, tick)
begin
	state_next <= state_reg;
	db <= '0';
	case state_reg is
		when zero =>
			if sw='1' then
				state_next <= wait1_1;
			end if;
		when wait1_1 =>
			if sw='0' then
				state_next <= zero;
			else -- sw='1'
				if tick='1' then
					state_next <= wait1_2;
				end if;
			end if;
		when wait1_2 =>
			if sw='0' then
				state_next <= zero;
			else -- sw='1'
				if tick='1' then
					state_next <= wait1_3;
				end if;
			end if;
		when wait1_3 =>
			if sw='0' then
				state_next <= zero;
			else -- sw='1'
				if tick='1' then
					state_next <= one;
				end if;
			end if;
		when one =>
			db <= '1';
			if sw='0' then
				state_next <= wait0_1;
			end if;
		when wait0_1 =>
			db <= '1';
			if sw='1' then
				state_next <= one;
			else -- sw='0'
				if tick='1' then
					state_next <= wait0_2;
				end if;
			end if;
		when wait0_2 =>
			db <= '1';
			if sw='1' then
				state_next <= one;
			else -- sw='0'
				if tick='1' then
					state_next <= wait0_3;
				end if;
			end if;
		when wait0_3 =>
			db <= '1';
			if sw='1' then
				state_next <= one;
			else -- sw='0'
				if tick='1' then
					state_next <= zero;
				end if;
			end if;
	end case;
end process;

end arch;