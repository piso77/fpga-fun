library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rotating_square is
	port(
		clk	: in  STD_LOGIC;
		en  	: in  STD_LOGIC;
		cw  	: in  STD_LOGIC;
		out0	: out  STD_LOGIC_VECTOR (7 downto 0);
		out1	: out  STD_LOGIC_VECTOR (7 downto 0);
		out2	: out  STD_LOGIC_VECTOR (7 downto 0);
		out3 	: out  STD_LOGIC_VECTOR (7 downto 0)
	);
end rotating_square;

architecture arch of rotating_square is
	-- refreshing rate around 1600Hz (100Mhz/2^16)
	constant N		: integer := 26;
	signal q_reg 	: unsigned(N-1 downto 0);
	signal q_next	: unsigned(N-1 downto 0);
	signal sel		: std_logic_vector(2 downto 0);
	-- squares -- XXX constant maybe???
	signal sqd: std_logic_vector(7 downto 0);
	signal squ: std_logic_vector(7 downto 0);
	signal sqnull: std_logic_vector(7 downto 0);
begin

	sqd <= "10100011";
	squ <= "10011100";
	sqnull <= "11111111";

	-- register
	process(clk)
	begin
		if (rising_edge(clk)) then
			q_reg <= q_next;
		end if;
	end process;

	-- next-state logic for the counter
	q_next <= q_reg + 1 when en='1' and cw='0' else
				 q_reg - 1 when en='1' and cw='1' else
				 q_reg ;
	
	-- 2 MSBs of counter to control 4-to-1 multiplexing
	-- and to generate active-low enable signal
	sel <= std_logic_vector(q_reg(N-1 downto N-3));
	process(sel, sqd, squ, sqnull)
	begin
		case sel is
			when "000" =>
				out0 <= squ;
				out1 <= sqnull;
				out2 <= sqnull;
				out3 <= sqnull;
			when "001" =>
				out0 <= sqnull;
				out1 <= squ;
				out2 <= sqnull;
				out3 <= sqnull;
			when "010" =>
				out0 <= sqnull;
				out1 <= sqnull;
				out2 <= squ;
				out3 <= sqnull;
			when "011" =>
				out0 <= sqnull;
				out1 <= sqnull;
				out2 <= sqnull;
				out3 <= squ;
			when "100" =>
				out0 <= sqnull;
				out1 <= sqnull;
				out2 <= sqnull;
				out3 <= sqd;
			when "101" =>
				out0 <= sqnull;
				out1 <= sqnull;
				out2 <= sqd;
				out3 <= sqnull;
			when "110" =>
				out0 <= sqnull;
				out1 <= sqd;
				out2 <= sqnull;
				out3 <= sqnull;
			when "111" =>
				out0 <= sqd;
				out1 <= sqnull;
				out2 <= sqnull;
				out3 <= sqnull;			
			when others => -- WTF?
				out0 <= sqnull;
				out1 <= sqnull;
				out2 <= sqnull;
				out3 <= sqnull;
		end case;
	end process;
end arch;