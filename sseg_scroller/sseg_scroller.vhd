library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sseg_scroller is
   port(
		clk : in  STD_LOGIC;
		en : in  STD_LOGIC;
		dir : in  STD_LOGIC;
		d0 : out  STD_LOGIC_VECTOR (3 downto 0);
		d1 : out  STD_LOGIC_VECTOR (3 downto 0);
		d2 : out  STD_LOGIC_VECTOR (3 downto 0);
		d3 : out  STD_LOGIC_VECTOR (3 downto 0)
	);
end sseg_scroller;

architecture arch of sseg_scroller is
	constant N: integer := 25;
	signal cnt_reg, cnt_next: unsigned(N-1 downto 0);
	signal tick: std_logic;
	signal n0_reg, n0_next: integer range 0 to 9 := 0;
	signal n1_reg, n1_next: integer range 0 to 9 := 1;
	signal n2_reg, n2_next: integer range 0 to 9 := 2;
	signal n3_reg, n3_next: integer range 0 to 9 := 3;
begin
process(clk)
begin
	if rising_edge(clk) then
		cnt_reg <= cnt_next;
		n0_reg <= n0_next;
		n1_reg <= n1_next;
		n2_reg <= n2_next;
		n3_reg <= n3_next;
	end if;
end process;

cnt_next <= cnt_reg+1 when en='1' else cnt_reg;

tick <= '1' when cnt_reg="0000000000000000000000000" else '0';

process(tick, dir, n0_reg, n1_reg, n2_reg, n3_reg)
begin
	if (tick='1') then
		if (dir='0') then
			n0_next <= n0_reg+1;
			n1_next <= n1_reg+1;
			n2_next <= n2_reg+1;
			n3_next <= n3_reg+1;
		else
			n0_next <= n0_reg-1;
			n1_next <= n1_reg-1;
			n2_next <= n2_reg-1;
			n3_next <= n3_reg-1;
		end if;
	else
		n0_next <= n0_reg;
		n1_next <= n1_reg;
		n2_next <= n2_reg;
		n3_next <= n3_reg;
	end if;
end process;

d0 <= std_logic_vector(to_unsigned(n0_reg, d0'length));
d1 <= std_logic_vector(to_unsigned(n1_reg, d1'length));
d2 <= std_logic_vector(to_unsigned(n2_reg, d2'length));
d3 <= std_logic_vector(to_unsigned(n3_reg, d3'length));
end arch;