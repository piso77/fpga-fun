library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reaction is
	port(
		clk : in  STD_LOGIC;
		clear : in  STD_LOGIC;
		start : in  STD_LOGIC;
		stop : in  STD_LOGIC;
		error : out STD_LOGIC;
		ready : out STD_LOGIC;
		led : out STD_LOGIC;
		done_tick: out STD_LOGIC;
		delay : out STD_LOGIC_VECTOR(12 downto 0)
	);
end reaction;

architecture arch of reaction is
	type state_type is (idle, waitr, run);
	signal state_reg, state_next: state_type;
	constant CLK_TO_MS: integer := 100000; 					-- 1ms tick
	signal ms_cnt, ms_cnt_next: unsigned(16 downto 0); 	-- up to CLK_TO_MS * 10ns = 1ms
	signal cnt, cnt_next: unsigned(12 downto 0);
	signal tmp: std_logic_vector(7 downto 0);
	-- XXX do we really need a rand_next???
	signal rand, rand_next: unsigned(11 downto 0);
begin

prng: entity work.pseudorng(arch)
		port map(
			clk => clk,
			reset => clear,
			en => '1',
			q => tmp,
			check => open
		);

process(clk, clear)
begin
	if (clear='1') then
		state_reg <= idle;
		ms_cnt <= (others => '0');
		cnt <= (others => '0');
		rand <= (others => '0');
	elsif rising_edge(clk) then
		state_reg <= state_next;
		ms_cnt <= ms_cnt_next;
		cnt <= cnt_next;
		rand <= rand_next;
	end if;
end process;

delay <= std_logic_vector(cnt);

process(state_reg, ms_cnt, cnt, start, stop, tmp, rand)
begin
	state_next <= state_reg;
	ms_cnt_next <= ms_cnt;
	cnt_next <= cnt;
	rand_next <= rand;
	error <= '0';
	ready <= '0';
	led <= '0';
	done_tick <= '0';
	case state_reg is
		when idle =>
			ready <= '1';
			if (start='1') then
				state_next <= waitr;
				ms_cnt_next <= (others => '0');
				cnt_next <= (others => '0');
				rand_next <= unsigned(tmp) & "0000";
			end if;
		when waitr =>
			if stop='1' then
				state_next <= idle;
				error <= '1';
				cnt_next <= to_unsigned(9999, cnt_next'length);
			-- wait rand ms
			elsif (cnt=rand) then
				state_next <= run;
				ms_cnt_next <= (others => '0');
				cnt_next <= (others => '0');
			elsif (ms_cnt=CLK_TO_MS) then
				ms_cnt_next <= (others => '0');
				cnt_next <= cnt+1;
			else
				ms_cnt_next <= ms_cnt+1;
			end if;
		when run =>
			led <= '1';
			if stop='1' or cnt=1000 then
				state_next <= idle;
				done_tick <= '1';
			elsif (ms_cnt=CLK_TO_MS) then
				ms_cnt_next <= (others => '0');
				cnt_next <= cnt+1;				
			else
				ms_cnt_next <= ms_cnt+1;
			end if;
	end case;
end process;

end arch;