----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:49:08 12/19/2018 
-- Design Name: 
-- Module Name:    sm_add_test - arch 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sm_add_test is
	port(
		clk : in  STD_LOGIC;
      btn : in  STD_LOGIC_VECTOR (1 downto 0);
      switch : in  STD_LOGIC_VECTOR (7 downto 0);
      an : out  STD_LOGIC_VECTOR (3 downto 0);
		--led :	out STD_LOGIC_VECTOR(1 downto 0);
      sseg : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end sm_add_test;

architecture arch of sm_add_test is
	signal sum, mout, oct			: std_logic_vector(3 downto 0);
	signal led3, led2, led1, led0	: std_logic_vector(7 downto 0);
begin
	-- adder
	sm_adder_unit: entity work.sign_mag_add(arch)
		generic map(N => 4)
		port map(
			a		=> switch(3 downto 0),
			b		=> switch(7 downto 4),
			sum	=> sum
		);

	-- 3-to-1 mux to select a number to display
	with btn select
		mout <= switch(3 downto 0) when "10", -- a
				  switch(7 downto 4) when "01", -- b
				  sum when others;			 -- sum
	
	-- debug btn
	--led <= btn;
	
	-- magnitude displayed on rightmost 7-seg LED
	oct <= '0' & mout(2 downto 0);
	sseg_unit: entity work.hex_to_sseg(arch)
		port map(
			hex => oct,
			dp => '1',
			sseg => led3
		);
		
	-- sign displayed on 2nd 7-seg LED
	led2 <= "10111111" when mout(3) = '1' else -- middle bar
			  "11111111";
	
	-- other two 7-seg LEDs blank
	led1 <= "11111111";
	led0 <= "11111111";
	
	--display muxer
	disp_unit: entity work.disp_mux(arch)
		port map(
			clk => clk,
			reset => '0',
			in0 => led0,
			in1 => led1,
			in2 => led2,
			in3 => led3,
			an => an,
			sseg => sseg
		);
end arch;