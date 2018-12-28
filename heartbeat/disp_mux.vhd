library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity disp_mux is
	port(
		clk : in  STD_LOGIC;
		reset : in  STD_LOGIC;
		in0 : in  STD_LOGIC_VECTOR (7 downto 0);
		in1 : in  STD_LOGIC_VECTOR (7 downto 0);
		in2 : in  STD_LOGIC_VECTOR (7 downto 0);
		in3 : in  STD_LOGIC_VECTOR (7 downto 0);
		an : out  STD_LOGIC_VECTOR (3 downto 0);
		sseg : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end disp_mux;

architecture arch of disp_mux is
	-- refreshing rate around 1600Hz (100Mhz/2^16)
	constant N		: integer := 18;
	signal q_reg 	: unsigned(N-1 downto 0);
	signal q_next	: unsigned(N-1 downto 0);
	signal sel		: std_logic_vector(1 downto 0);
begin
	-- register
	process(clk, reset)
	begin
	if reset = '1' then
		q_reg <= (others => '0');
	elsif (rising_edge(clk)) then
		q_reg <= q_next;
	end if;
	end process;

	-- next-state logic for the counter
	q_next <= q_reg + 1;
	
	-- 2 MSBs of counter to control 4-to-1 multiplexing
	-- and to generate active-low enable signal
	sel <= std_logic_vector(q_reg(N-1 downto N-2));
	process(sel, in0, in1, in2, in3)
	begin
		case sel is
			when "00" =>
				an(3 downto 0) <= "1110";
				sseg <= in0;
			when "01" =>
				an(3 downto 0) <= "1101";
				sseg <= in1;
			when "10" =>
				an(3 downto 0) <= "1011";
				sseg <= in2;
			when "11" =>
				an(3 downto 0) <= "0111";
				sseg <= in3;
			when others => -- WTF?
				an(3 downto 0) <= "0000";
				sseg <= "00000000";
		end case;
	end process;

end arch;