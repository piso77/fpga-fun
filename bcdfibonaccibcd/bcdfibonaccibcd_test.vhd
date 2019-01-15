library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bcdfibonaccibcd_test is
	port(
		clk : in  STD_LOGIC;
		switch : in  STD_LOGIC_VECTOR (7 downto 0);
		btn : STD_LOGIC_VECTOR(1 downto 0);
		led : out  STD_LOGIC_VECTOR (4 downto 0);
		an : out  STD_LOGIC_VECTOR (3 downto 0);
		sseg : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end bcdfibonaccibcd_test;

architecture fsmd of bcdfibonaccibcd_test is
	type state is (idle, bcdtob, fibona, bintob, waito);
	signal state_reg, state_next: state;
	signal start, reset : std_logic;
	signal startbcd, donebcd : std_logic;
	signal startfib, donefib : std_logic;
	signal startbin, donebin : std_logic;
	signal overflow : std_logic;
	signal binary : std_logic_vector(6 downto 0);
	signal fibo : std_logic_vector(12 downto 0);
	signal tmp : std_logic_vector(13 downto 0);
	signal bcds : std_logic_vector(15 downto 0);
begin

start <= not btn(0);
reset <= not btn(1);

process(clk, reset)
begin
	if (reset='1') then
		state_reg <= idle;
	elsif rising_edge(clk) then
		state_reg <= state_next;
	end if;
end process;

process(state_reg, start, donebcd, donefib, donebin)
begin
	state_next <= state_reg;
	startbcd <= '0';
	startfib <= '0';
	startbin <= '0';
	case state_reg is
		when idle =>
			if start='1' then
				startbcd <= '1';
				state_next <= bcdtob;
				led <= "00001";
			end if;
			led <= "10001";
		when bcdtob =>
			if donebcd='1' then
				startfib <= '1';
				state_next <= fibona;				
				led <= "00010";
			end if;
			led <= "10010";
		when fibona =>
			if donefib='1' then
				startbin <= '1';
				state_next <= bintob;
				led <= "00100";
			end if;
			led <= "10100";
		when bintob =>
			if donebin='1' then
				state_next <= waito;
				led <= "01000";
			end if;
			led <= "11000";
		when others =>
			led <= "11111";
	end case;
end process;

bcdtobin: entity work.bcdtobin(fsmd)
	port map(
		clk => clk,
		reset => reset,
		start => startbcd,
		done => donebcd,
		bcdl => switch(7 downto 4),
		bcdh => switch(3 downto 0),
		bin => binary
	);

fib: entity work.fibonacci(arch)
	generic map(outbit => 13)
	port map(
		clk => clk,
		reset => reset,
		start => startfib,
		i => binary(4 downto 0),
		ready => open,
		done_tick => donefib,
		overflow => overflow,
		f => fibo
	);

tmp <= '0'&fibo when overflow='0' else "10011100001111"; -- 9999 in binary

bintobcd: entity work.bin2bcd(arch)
	generic map(WIDTH => 14)
	port map(
		clk => clk,
		reset => reset,
		start => startbin,
		bin => tmp,
		ready => open,
		done_tick => donebin,
		bcd0 => bcds(15 downto 12),
		bcd1 => bcds(11 downto 8),
		bcd2 => bcds(7 downto 4),
		bcd3 => bcds(3 downto 0)
	);

dispmux: entity work.disp_hex_mux(arch)
	port map(
		clk => clk,
		reset => reset,
		hex3 => bcds(15 downto 12),
		hex2 => bcds(11 downto 8),
		hex1 => bcds(7 downto 4),
		hex0 => bcds(3 downto 0),
		dp_in => "1111",
		an => an,
		sseg => sseg
	);

end fsmd;

--architecture cascade_signals of bcdfibonaccibcd_test is
--	signal start, donebcd, donefib, donebin : std_logic;
--	signal binary : std_logic_vector(6 downto 0);
--	signal fibo : std_logic_vector(19 downto 0);
--	signal bcds : std_logic_vector(15 downto 0);
--begin
--
--start <= not btn;
--
--bcdtobin: entity work.bcdtobin(arch)
--	port map(
--		clk => clk,
--		start => start,
--		done => donebcd,
--		bcdl => switch(7 downto 4),
--		bcdh => switch(3 downto 0),
--		bin => binary
--	);
--
--fib: entity work.fibonacci(arch)
--	port map(
--		clk => clk,
--		reset => '0',
--		start => donebcd,
--		i => binary(4 downto 0),
--		ready => open,
--		done_tick => donefib,
--		f => fibo
--	);
--
--bintobcd: entity work.bin2bcd(arch)
--	port map(
--		clk => clk,
--		reset => '0',
--		start => donefib,
--		bin => fibo(12 downto 0),
--		ready => open,
--		done_tick => donebin,
--		bcd0 => bcds(15 downto 12),
--		bcd1 => bcds(11 downto 8),
--		bcd2 => bcds(7 downto 4),
--		bcd3 => bcds(3 downto 0)
--	);
--
--dispmux: entity work.disp_hex_mux(arch)
--	port map(
--		clk => clk,
--		reset => '0',
--		hex3 => bcds(15 downto 12),
--		hex2 => bcds(11 downto 8),
--		hex1 => bcds(7 downto 4),
--		hex0 => bcds(3 downto 0),
--		dp_in => "1111",
--		an => an,
--		sseg => sseg
--	);
--
--end cascade_signals;



--architecture test of bcdfibonaccibcd_test is
--	signal tmp : std_logic_vector(19 downto 0);
--	signal reset, start : std_logic;
--begin
--
--reset <= switch(0);
--start <= switch(1);
--
--fib: entity work.fibonacci(arch)
--	port map(
--		clk => clk,
--		reset => reset,
--		start => start,
--		i => switch(6 downto 2),
--		ready => led(0),
--		done_tick => led(1),
--		f => tmp
--	);
--
--led(7 downto 2) <= tmp(5 downto 0);
--
--dispmux: entity work.disp_hex_mux(arch)
--	port map(
--		clk => clk,
--		reset => reset,
--		hex0 => tmp(15 downto 12),
--		hex1 => tmp(11 downto 8),
--		hex2 => tmp(7 downto 4),
--		hex3 => tmp(3 downto 0),
--		dp_in => "1111",
--		an => an,
--		sseg => sseg
--	);
--
--end test;