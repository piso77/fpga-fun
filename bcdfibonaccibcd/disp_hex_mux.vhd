library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity disp_hex_mux is
   port(
		clk : in  STD_LOGIC;
		reset : in  STD_LOGIC;
		hex0 : in  STD_LOGIC_VECTOR (3 downto 0);
		hex1 : in  STD_LOGIC_VECTOR (3 downto 0);
		hex2 : in  STD_LOGIC_VECTOR (3 downto 0);
		hex3 : in  STD_LOGIC_VECTOR (3 downto 0);
		dp_in : in  STD_LOGIC_VECTOR (3 downto 0);
		an : out  STD_LOGIC_VECTOR (3 downto 0);
		sseg : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end disp_hex_mux;

architecture arch of disp_hex_mux is
	constant N: integer := 18;
	signal r_reg, r_next: unsigned(N-1 downto 0);
	signal sel: std_logic_vector(1 downto 0);
	signal hex: std_logic_vector(3 downto 0);
	signal dp: std_logic;
begin

-- counter used for time-multiplexing
process(clk, reset)
begin
	if (reset='1') then
		r_reg <= (others => '0');
	elsif rising_edge(clk) then
		r_reg <= r_next;
	end if;
end process;
r_next <= r_reg + 1;
-- 2 MSBs of counter used to control 4-to-1 multiplexing
sel <= std_logic_vector(r_reg(N-1 downto N-2));

process(reset, sel, hex0, hex1, hex2, hex3, dp_in)
begin
	if reset='1' then
		an <= "0000";
		hex <= "0000";
		dp <= '1';
	else
		case sel is
			when "00" =>
				an <= "1110";
				hex <= hex0;
				dp <= dp_in(0);
			when "01" =>
				an <= "1101";
				hex <= hex1;
				dp <= dp_in(1);
			when "10" =>
				an <= "1011";
				hex <= hex2;
				dp <= dp_in(2);
			when others =>
				an <= "0111";
				hex <= hex3;
				dp <= dp_in(3);
		end case;
	end if;
end process;

-- hex to 7-segs decoding
with hex select 
	sseg(6 downto 0) <=
		"1000000" when "0000",
		"1111001" when "0001",
		"0100100" when "0010",
		"0110000" when "0011",
		"0011001" when "0100",
		"0010010" when "0101",
		"0000010" when "0110",
		"1111000" when "0111",
		"0000000" when "1000",
		"0010000" when "1001",
		"0001000" when "1010",
		"0000011" when "1011",
		"1000110" when "1100",
		"0100001" when "1101",
		"0000110" when "1110",
		"0001110" when others;
-- decimal point
sseg(7) <= dp;
end arch;