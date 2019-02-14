library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
	signal clko 	: std_logic;
	signal hcount	: unsigned(9 downto 0) := (others => '0');
	signal vcount	: unsigned(9 downto 0) := (others => '0');
	signal addr : std_logic_vector(15 downto 0) := (others => '0');
	signal tmp : std_logic_vector(19 downto 0) := (others => '0');
	signal data : std_logic_vector(7 downto 0) := (others => '0');
begin

clk25mhz : entity work.clk_wiz_v3_6(xilinx)
	port map(
    CLK_IN1 => clk,
    CLK_OUT1 => clko
	);

vrom : entity work.blk_mem_gen_v7_3(blk_mem_gen_v7_3_a)
  PORT MAP (
    clka => clko,
    addra => addr,
    douta => data
  );

process(clko)
begin
	if rising_edge(clko) then
		if hcount=799 then
			hcount <= (others => '0');
			if vcount=524 then
				vcount <= (others => '0');
			else
				vcount <= vcount + 1;
			end if;
		else
			hcount <= hcount + 1;
		end if;
	end if;
end process;

tmp <= std_logic_vector(shift_right(hcount, 1) + (shift_right(vcount, 1) * 320));
addr <= tmp(15 downto 0);

process(hcount, vcount, data)
begin
	vga_hsync <= '1';
	vga_vsync <= '1';
	vga_blue <= "00";
	vga_green <= "000";
	vga_red <= "000";

	if vcount >= 490 and vcount < 492 then
		vga_vsync <= '0';
	end if;

	if hcount >= 656 and hcount < 752 then
		vga_hsync <= '0';
	end if;

--	if hcount < 640 then
--		if vcount < 160 then
--			vga_blue 	<= "00";
--			vga_green 	<= "000";
--			vga_red 		<= "111";
--		elsif vcount < 320 then
--			vga_blue 	<= "00";
--			vga_green 	<= "111";
--			vga_red 		<= "000";
--		elsif vcount < 480 then
--			vga_blue 	<= "11";
--			vga_green 	<= "000";
--			vga_red 		<= "000";
--		end if;
--	end if;
	if hcount < 640 and vcount < 400 then
		vga_red <= data(7 downto 5);
		vga_green <= data(4 downto 2);
		vga_blue <= data(1 downto 0);
	end if;
end process;

end arch;