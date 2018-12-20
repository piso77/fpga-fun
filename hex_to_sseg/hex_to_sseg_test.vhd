----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:51:02 12/18/2018 
-- Design Name: 
-- Module Name:    hex_to_sseg_test - arch 
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

entity hex_to_sseg_test is
	port(
		clk : in  STD_LOGIC;
		switch : in  STD_LOGIC_VECTOR (7 downto 0);
		an : out  STD_LOGIC_VECTOR (3 downto 0);
		sseg : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end hex_to_sseg_test;

architecture arch of hex_to_sseg_test is
	signal inc			: std_logic_vector(7 downto 0);
	signal led0, led1	: std_logic_vector(7 downto 0);
	signal led2, led3	: std_logic_vector(7 downto 0);
begin
	-- increment input
	inc <= std_logic_vector(unsigned(switch) + 1);
	-- 4 LSBs of input
	sseg0: entity work.hex_to_sseg(arch)
		port map(
			hex	=> switch(3 downto 0),
			dp  	=> '0',
			sseg	=> led0
		);
	-- 4 MSBs of input
	sseg1: entity work.hex_to_sseg(arch)
		port map(
			hex	=> switch(7 downto 4),
			dp  	=> '0',
			sseg	=> led1
		);
	-- 4 LSBs of incremented value
	sseg2: entity work.hex_to_sseg(arch)
		port map(
			hex	=> inc(3 downto 0),
			dp  	=> '1',
			sseg	=> led2
		);
	-- 4 MSBs of incremented value
	sseg3: entity work.hex_to_sseg(arch)
		port map(
			hex	=> inc(7 downto 4),
			dp  	=> '1',
			sseg	=> led3
		);
	-- sseg mux
	mux: entity work.disp_mux(arch)
		port map(
			clk	=> clk,
			reset	=> '0',
			in0	=> led0,
			in1	=> led1,
			in2 	=> led2,
			in3	=> led3,
			an		=> an,
			sseg	=> sseg
		);
end arch;

