library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bcdtobin_test is
    Port ( clk : in  STD_LOGIC;
           btn : in  STD_LOGIC;
           switch : in  STD_LOGIC_VECTOR (7 downto 0);
           an : out  STD_LOGIC_VECTOR (3 downto 0);
           sseg : out  STD_LOGIC_VECTOR (7 downto 0));
end bcdtobin_test;

architecture arch of bcdtobin_test is
	signal bin: std_logic_vector(6 downto 0);
	signal tmp: std_logic_vector(3 downto 0);
	signal rst: std_logic;
begin

	rst <= not btn;

	bdctobin: entity work.bcdtobin(arch)
		port map(
			clk => clk,
			rst => rst,
			bcd => switch,
			bin => bin
		);

	tmp <= '0' & bin(6 downto 4);

	disp: entity work.disp_hex_mux(arch)
		port map(
			clk => clk,
			reset => rst,
			hex0 => switch(7 downto 4),
			hex1 => switch(3 downto 0),
			hex2 => tmp,
			hex3 => bin(3 downto 0),
			dp_in => "1100",
			an => an,
			sseg => sseg
		);

end arch;