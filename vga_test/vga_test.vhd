library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_test is
	generic(
		h_area			: integer := 640;	-- horizontal display area in pixels
		h_fp			: integer := 16;	-- horizontal front porch in pixels
		h_sp			: integer := 96;	-- horizontal sync pulse in pixels
		h_bp			: integer := 48;	-- horizontal back porch in pixels
		v_area			: integer := 480;	-- vertical display area in pixels
		v_fp			: integer := 10;	-- vertical front porch in pixels
		v_sp			: integer := 2;		-- vertical sync pulse in pixels
		v_bp			: integer := 33		-- vertical back porch in pixels
	);
	port(
		clk				: in  STD_LOGIC;
		hsync			: out  STD_LOGIC;
		vsync			: out  STD_LOGIC;
		blue			: out  STD_LOGIC_VECTOR (1 downto 0);
		green			: out  STD_LOGIC_VECTOR (2 downto 0);
		red				: out  STD_LOGIC_VECTOR (2 downto 0)
	);
end vga_test;

architecture arch of vga_test is
	constant h_period	: integer := h_sp + h_bp + h_area + h_fp;  --total number of pixel clocks in a row
	constant v_period	: integer := v_sp + v_bp + v_area + v_fp;  --total number of rows in column
	signal clko			: std_logic;
	signal hcount		: unsigned(9 downto 0) := (others => '0');
	signal vcount		: unsigned(9 downto 0) := (others => '0');
	signal addr			: std_logic_vector(15 downto 0) := (others => '0');
	signal tmp			: std_logic_vector(19 downto 0) := (others => '0');
	signal data			: std_logic_vector(7 downto 0) := (others => '0');
begin

clk25mhz : entity work.clk_wiz_v3_6(xilinx)
	port map(
		CLK_IN1 => clk,
		CLK_OUT1 => clko
	);

vrom : entity work.video_rom(video_rom)
  PORT MAP (
    clka => clko,
    addra => addr,
    douta => data
  );

process(clko)
begin
	if rising_edge(clko) then
		if (hcount = h_period-1) then
			hcount <= (others => '0');
			if (vcount = v_period-1) then
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
	hsync <= '1';
	vsync <= '1';
	blue <= "00";
	green <= "000";
	red <= "000";

	if (vcount >= v_area+v_fp and vcount < v_area+v_fp+v_sp) then
		vsync <= '0';
	end if;

	if (hcount >= h_area+h_fp and hcount < h_area+h_fp+h_sp) then
		hsync <= '0';
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
		red <= data(7 downto 5);
		green <= data(4 downto 2);
		blue <= data(1 downto 0);
	end if;
end process;

end arch;
