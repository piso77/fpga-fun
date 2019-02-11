library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_test is
	port(
		clk : in  STD_LOGIC;
		vga_hsync : in  STD_LOGIC;
		vga_vsync : in  STD_LOGIC;
		vga_blue : in  STD_LOGIC_VECTOR (1 downto 0);
		vga_green : in  STD_LOGIC_VECTOR (2 downto 0);
		vga_red : in  STD_LOGIC_VECTOR (2 downto 0)
	);
end vga_test;

architecture arch of vga_test is

begin


end arch;

