library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bcdtobin is
	port(
		clk : in  STD_LOGIC;
		start : in  STD_LOGIC;
		reset : in STD_LOGIC;
		done: out STD_LOGIC;
		bcdl : in  STD_LOGIC_VECTOR (3 downto 0);
		bcdh : in  STD_LOGIC_VECTOR (3 downto 0);
		bin : out  STD_LOGIC_VECTOR (6 downto 0)
	);
end bcdtobin;

architecture fsmd of bcdtobin is
	type state is (idle, op, result);
	signal state_reg, state_next : state;
	signal dig1_reg, dig1_next: integer range 0 to 9;
	signal dig2_reg, dig2_next: integer range 0 to 9;
	signal dig1, dig2: integer;
	signal sum: integer;
begin

	process(clk, reset)
	begin
		if (reset='1') then
			state_reg <= idle;
			dig1_reg <= 0;
			dig2_reg <= 0;
		elsif rising_edge(clk) then
			state_reg <= state_next;
			dig1_reg <= dig1_next;
			dig2_reg <= dig2_next;
		end if;
	end process;

	dig1 <= to_integer(unsigned(bcdh));
	dig2 <= to_integer(unsigned(bcdl));

	process(state_reg, start, dig1_reg, dig2_reg, dig1, dig2)
	begin
		state_next <= state_reg;
		dig1_next <= dig1_reg;
		dig2_next <= dig2_reg;
		done <= '0';
		case state_reg is
			when idle =>
				if start='1' then
					state_next <= op;
				end if;
			when op =>
				state_next <= result;
				dig1_next <= 9;
				dig2_next <= 9;
				if dig1 <= 9 then
					dig1_next <= dig1;
				end if;
				if dig2 <= 9 then
					dig2_next <= dig2;
				end if;
			when result =>
				state_next <= idle;
				done <= '1';
		end case;
	end process;

	sum <= dig1_reg*10 + dig2_reg;
	bin <= std_logic_vector(to_unsigned(sum, bin'length));
end fsmd;



--architecture arch of bcdtobin is
--	signal dig1_reg, dig1_next: integer range 0 to 9;
--	signal dig2_reg, dig2_next: integer range 0 to 9;
--	signal dig1, dig2: integer;
--	signal sum: integer;
--begin
--
--	process(clk, reset, start)
--	begin
--		if (reset='1') then
--			dig1_reg <= 0;
--			dig2_reg <= 0;
--			done <= '0';
--		elsif rising_edge(clk) then
--			dig1_reg <= dig1_next;
--			dig2_reg <= dig2_next;
--			if start='1' then
--				done <= '1';
--			end if;
--		end if;
--	end process;
--
--	dig1 <= to_integer(unsigned(bcdh));
--	dig2 <= to_integer(unsigned(bcdl));
--	dig1_next <= dig1 when dig1 <= 9 else 9;
--	dig2_next <= dig2 when dig2 <= 9 else 9;
--	sum <= dig1_reg*10 + dig2_reg;
--
--	bin <= std_logic_vector(to_unsigned(sum, bin'length));
--end arch;