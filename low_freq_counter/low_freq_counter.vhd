library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity low_freq_counter is
	port(
		clk : in  STD_LOGIC;
		reset : in  STD_LOGIC;
		start : in  STD_LOGIC;
		si : in  STD_LOGIC;
		bcd3 : out  STD_LOGIC_VECTOR (3 downto 0);
		bcd2 : out  STD_LOGIC_VECTOR (3 downto 0);
		bcd1 : out  STD_LOGIC_VECTOR (3 downto 0);
		bcd0 : out  STD_LOGIC_VECTOR (3 downto 0)
	);
end low_freq_counter;

architecture arch of low_freq_counter is
	type state_type is (idle, count, frq, b2b);
	signal state_reg, state_next: state_type;
	
	signal period: std_logic_vector(9 downto 0);
	signal dvsr, dvnd, quo: std_logic_vector(19 downto 0);
	
	signal period_done, period_start: std_logic;
	signal division_done, division_start: std_logic;
	signal bin2bcd_done, bin2bcd_start: std_logic;
begin

	periodcounter: entity work.period_counter(arch)
	port map(
		clk => clk,
		reset => reset,
		start => period_start,
		si => si,
		prd => period,
		ready => open,
		done_tick => period_done
	);
	
	divisioncircuit: entity work.division(arch)
	generic map(
		W => 20,
		CBIT => 5
	)
	port map(
		clk => clk,
		reset => reset,
		start => division_start,
		ready => open,
		done_tick => division_done,
		dvsr => dvsr,
		dvnd => dvnd,
		rmd => open,
		quo => quo
	);

	bin2bcd: entity work.bin2bcd(arch)
	port map(
		clk => clk,
		reset => reset,
		start => bin2bcd_start,
		ready => open,
		done_tick => bin2bcd_done,
		bin => quo(12 downto 0),
		bcd3 => bcd3,
		bcd2 => bcd2,
		bcd1 => bcd1,
		bcd0 => bcd0
	);

	dvnd <= std_logic_vector(to_unsigned(1000000, 20));
	dvsr <= "0000000000" & period;

	process(clk, reset)
	begin
		if reset='1' then
			state_reg <= idle;
		elsif rising_edge(clk) then
			state_reg <= state_next;
		end if;
	end process;

	process(state_reg, start, period_done, division_done, bin2bcd_done)
	begin
		state_next <= state_reg;
		period_start <= '0';
		division_start <= '0';
		bin2bcd_start <= '0';
		case state_reg is
			when idle =>
				if start='1' then
					period_start <= '1';
					state_next <= count;
				end if;
			when count =>
				if period_done='1' then
					division_start <= '1';
					state_next <= frq;
				end if;
			when frq =>
				if division_done='1' then
					bin2bcd_start <= '1';
					state_next <= b2b;
				end if;
			when b2b =>
				if bin2bcd_done='1' then
					state_next <= idle;
				end if;
		end case;
	end process;

end arch;