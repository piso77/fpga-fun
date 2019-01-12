library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fibonacci is
	generic(
		inbit: integer := 5;
		outbit: integer := 20
	);
	port(
		clk : in  STD_LOGIC;
		reset : in  STD_LOGIC;
		start : in  STD_LOGIC;
		i : in  STD_LOGIC_VECTOR (inbit-1 downto 0);
		ready : out  STD_LOGIC;
		done_tick : out  STD_LOGIC;
		f : out  STD_LOGIC_VECTOR (outbit-1 downto 0)
	);
end fibonacci;

architecture arch of fibonacci is
	type state_type is (idle, op, done);
	signal state_reg, state_next: state_type;
	signal n_reg, n_next: unsigned(inbit-1 downto 0);
	signal t0_reg, t0_next: unsigned(outbit-1 downto 0);
	signal t1_reg, t1_next: unsigned(outbit-1 downto 0);
begin

process(clk, reset)
begin
	if (reset='1') then
		state_reg <= idle;
		t0_reg <= (others => '0');
		t1_reg <= (others => '0');
		n_reg <= (others => '0');
	elsif rising_edge(clk) then
		state_reg <= state_next;
		t0_reg <= t0_next;
		t1_reg <= t1_next;
		n_reg <= n_next;
	end if;
end process;

process(state_reg, i, n_reg, t0_reg, t1_reg, start)
begin
	ready <= '0'; 
	done_tick <= '0';
	state_next <= state_reg;
	t0_next <= t0_reg;
	t1_next <= t1_reg;
	n_next <= n_reg;
	case state_reg is
		when idle =>
			ready <= '1';
			if start='1' then
				t0_next <= (others => '0');
				t1_next <= (0 => '1', others => '0');
				n_next <= unsigned(i);
				state_next <= op;
			end if;
		when op =>
			if n_reg=0 then
				t1_next <= (others => '0');
				state_next <= done;
			elsif n_reg=1 then
				state_next <= done;
			else
				t0_next <= t1_reg;
				t1_next <= t1_reg + t0_reg;
				n_next <= n_reg - 1;
			end if;
		when done =>
			done_tick <= '1';
			state_next <= idle;
	end case;
end process;

f <= std_logic_vector(t1_reg);
end arch;