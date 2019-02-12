library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_test is
	port(
		clk : in  STD_LOGIC;
		vga_hsync : out  STD_LOGIC;
		vga_vsync : out  STD_LOGIC;
		vga_blue : out  STD_LOGIC_VECTOR (1 downto 0);
		vga_green : out  STD_LOGIC_VECTOR (2 downto 0);
		vga_red : out  STD_LOGIC_VECTOR (2 downto 0)
	);
end vga_test;

architecture arch of vga_test is
	signal clko : std_logic;
	signal hcount, hcount_next : unsigned(9 downto 0);
	signal vcount, vcount_next : unsigned(9 downto 0);
begin

clk25mhz : entity work.clk_wiz_v3_6(xilinx)
  port map
   (-- Clock in ports
    CLK_IN1 => clk,
    -- Clock out ports
    CLK_OUT1 => clko);

process(clko)
begin
	if rising_edge(clko) then
		hcount <= hcount_next;
		vcount <= vcount_next;
	end if;
end process;

process(hcount, vcount)
begin
	vcount_next <= vcount;
	if hcount=799 then
		hcount_next <= (others => '0');
		if vcount=524 then
			vcount_next <= (others => '0');
		else
			vcount_next <= vcount + 1;
		end if;
	else
		hcount_next <= hcount + 1;
	end if;

	if vcount >= 490 and vcount < 492 then
		vga_vsync <= '0';
	else
		vga_vsync <= '1';
	end if;

	if hcount >= 656 and hcount < 752 then
		vga_hsync <= '0';
	else
		vga_hsync <= '1';
	end if;

	if hcount < 640 and vcount < 480 then
		vga_blue <= "10";
		vga_green <= "010";
		vga_red <= "101";
	else
		vga_blue <= "00";
		vga_green <= "000";
		vga_red <= "000";
	end if;

end process;


end arch;