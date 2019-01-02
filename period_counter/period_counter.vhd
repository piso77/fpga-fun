library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity period_counter is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           start : in  STD_LOGIC;
           si : in  STD_LOGIC;
           ready : out  STD_LOGIC;
           done_tick : out  STD_LOGIC;
           prd : out  STD_LOGIC_VECTOR (9 downto 0));
end period_counter;

architecture arch of period_counter is
	constant CLK_MS_COUNT: integer := 100000; -- 1ms tick
	type state_type is (idle, waite, count, done);
	signal state_reg, state_next: state_type;
	signal t_reg, t_next: unsigned(16 downto 0); -- up to 100000
	signal p_reg, p_next: unsigned(9 downto 0); -- up to 1 sec
	signal delay_reg, edge: std_logic;
begin

process(clk, reset)
begin
	if reset='1' then
		state_reg <= idle;
		p_reg <= (others => '0');
		t_reg <= (others => '0');
		delay_reg <= '0';
	elsif rising_edge(clk) then
		state_reg <= state_next;
		p_reg <= p_next;
		t_reg <= t_next;
		delay_reg <= si;
	end if;
end process;

-- edge detection
edge <= (not delay_reg) and si;

process(state_reg, edge, p_reg, t_reg, start)
begin
	state_next <= state_reg;
	p_next <= p_reg;
	t_next <= t_reg;
	ready <= '0';
	done_tick <= '0';
	case state_reg is
		when idle =>
			ready <= '1';
			if start='1' then
				state_next <= waite;
			end if;
		when waite => -- wait for the first edge
			if edge='1' then
				t_next <= (others => '0');
				p_next <= (others => '0');
				state_next <= count;
			end if;
		when count =>
			if edge='0' then -- count
				if t_reg = CLK_MS_COUNT-1 then -- 1ms tick
					t_next <= (others => '0');
					p_next <= p_reg + 1;
				else
					t_next <= t_reg + 1;
				end if;
			else -- 2nd edge arrived
				state_next <= done;
			end if;
		when done =>
			done_tick <= '1';
			state_next <= idle;
	end case;
end process;

prd <= std_logic_vector(p_reg);

end arch;