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
		done: out STD_LOGIC;
		bcd : in  STD_LOGIC_VECTOR (7 downto 0);
		bin : out  STD_LOGIC_VECTOR (6 downto 0)
	);
end bcdtobin;

architecture arch of bcdtobin is
	signal dig1_reg, dig1_next: integer range 0 to 9;
	signal dig2_reg, dig2_next: integer range 0 to 9;
	signal dig1, dig2: integer;
	signal sum: integer;
begin

	process(clk, start)
	begin
		if (start='0') then
			dig1_reg <= 0;
			dig2_reg <= 0;
			done <= '0';
		elsif rising_edge(clk) then
			dig1_reg <= dig1_next;
			dig2_reg <= dig2_next;
			done <= '1';
		end if;
	end process;

	dig1 <= to_integer(unsigned(bcd(7 downto 4)));
	dig2 <= to_integer(unsigned(bcd(3 downto 0)));
	dig1_next <= dig1 when dig1 <= 9 else 9;
	dig2_next <= dig2 when dig2 <= 9 else 9;
	sum <= dig1_reg*10 + dig2_reg;

	bin <= std_logic_vector(to_unsigned(sum, bin'length));
end arch;

