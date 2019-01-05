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
		rst : in  STD_LOGIC;
		bcd : in  STD_LOGIC_VECTOR (7 downto 0);
		bin : out  STD_LOGIC_VECTOR (6 downto 0)
	);
end bcdtobin;

architecture arch of bcdtobin is
	signal dig1_reg, dig1_next: integer range 0 to 9;
	signal dig2_reg, dig2_next: integer range 0 to 9;
	signal sum: integer;
begin

	process(clk, rst)
	begin
		if (rst='1') then
			dig1_reg <= 0;
			dig2_reg <= 0;
		elsif rising_edge(clk) then
			dig1_reg <= dig1_next;
			dig2_reg <= dig2_next;
		end if;
	end process;

	dig1_next <= to_integer(unsigned(bcd(7 downto 4)));
	dig2_next <= to_integer(unsigned(bcd(3 downto 0)));
	sum <= dig1_reg*10 + dig2_reg;

	bin <= std_logic_vector(to_unsigned(sum, bin'length));
end arch;

