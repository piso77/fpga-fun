library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity heartbeat is
	port(
		clk : in  STD_LOGIC;
		en : in  STD_LOGIC;
		out0 : out  STD_LOGIC_VECTOR (7 downto 0);
		out1 : out  STD_LOGIC_VECTOR (7 downto 0);
		out2 : out  STD_LOGIC_VECTOR (7 downto 0);
		out3 : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end heartbeat;

architecture arch of heartbeat is
	constant WIDTH: integer := 24;
	signal c_reg, c_next: unsigned(WIDTH-1 downto 0);
	signal cnt_reg, cnt_next: integer range 0 to 2 := 0;
	signal sel: std_logic_vector(WIDTH-1 downto WIDTH-2);
	signal rx, sx, snull: std_logic_vector(7 downto 0); 
begin

rx <= "11111001";
sx <= "11001111";
snull <= "11111111";

process(clk)
begin
	if (rising_edge(clk)) then
		c_reg <= c_next;
		cnt_reg <= cnt_next;
	end if;
end process;

c_next <= c_reg+1 when en='1' else c_reg;

cnt_next <= cnt_reg+1 when c_reg="111111111111111111111111" else cnt_reg;

process(cnt_reg, rx, sx, snull)
begin
	case cnt_reg is
		when 0 =>
			out0 <= snull;
			out1 <= rx;
			out2 <= sx;
			out3 <= snull;
		when 1 =>
			out0 <= snull;
			out1 <= sx;
			out2 <= rx;
			out3 <= snull;
--		when "10" =>
--			out0 <= rx;
--			out1 <= snull;
--			out2 <= snull;
--			out3 <= sx;
		when 2 =>
			out0 <= sx;
			out1 <= snull;
			out2 <= snull;
			out3 <= rx;
		when others =>
			out0 <= snull;
			out1 <= snull;
			out2 <= snull;
			out3 <= snull;
	end case;
end process;

--process(sel, rx, sx, snull)
--begin
--	case sel is
--		when "00" =>
--			out0 <= snull;
--			out1 <= rx;
--			out2 <= sx;
--			out3 <= snull;
--		when "01" =>
--			out0 <= snull;
--			out1 <= sx;
--			out2 <= rx;
--			out3 <= snull;
--		when "10" =>
--			out0 <= rx;
--			out1 <= snull;
--			out2 <= snull;
--			out3 <= sx;
--		when "11" =>
--			out0 <= sx;
--			out1 <= snull;
--			out2 <= snull;
--			out3 <= rx;
--		when others =>
--			out0 <= snull;
--			out1 <= snull;
--			out2 <= snull;
--			out3 <= snull;
--	end case;
--end process;

end arch;