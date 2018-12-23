library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity univ_bin_counter is
	generic(N: integer := 8);
	port(
		clk		: in	STD_LOGIC;
		reset 	: in	STD_LOGIC;
		sync_clr	: in	STD_LOGIC;
		load		: in	STD_LOGIC;
		en			: in	STD_LOGIC;
		up			: in	STD_LOGIC;
		d			: in	STD_LOGIC_VECTOR(N-1 downto 0);
		max_tick : out	STD_LOGIC;
		min_tick	: out	STD_LOGIC;
		q			: out	STD_LOGIC_VECTOR(N-1 downto 0)
	);
end univ_bin_counter;

architecture arch of univ_bin_counter is
	signal r_reg, r_next: unsigned(N-1 downto 0);
begin
-- register
process(clk, reset)
begin
	if (reset='1') then
		r_reg <= (others => '0');
	elsif rising_edge(clk) then
		r_reg <= r_next;
	end if;
end process;

-- next state logic
r_next <= (others => '0') when sync_clr='1' else
			 unsigned(d) when load='1' else
			 r_reg + 1 when en='1' and up='1' else
			 r_reg - 1 when en='1' and up='0' else
			 r_reg;

-- output
q <= std_logic_vector(r_reg);
max_tick <= '1' when r_reg=(2**N - 1) else '0';
min_tick <= '1' when r_reg=0 else '0';
end arch;