----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:45:01 12/21/2018 
-- Design Name: 
-- Module Name:    shift_reg_top - arch 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity shift_reg_top is
   port(
		clk : 	in STD_LOGIC;
		switch :	in  STD_LOGIC_VECTOR (7 downto 0);
		joyu :		in  STD_LOGIC;
		joyd :		in  STD_LOGIC;
		joyl :		in  STD_LOGIC;
		joyr :		in  STD_LOGIC;
		led :		out  STD_LOGIC_VECTOR (7 downto 0)
	);
end shift_reg_top;

architecture arch of shift_reg_top is
	signal reset: STD_LOGIC;
	signal dir: STD_LOGIC_VECTOR(1 downto 0);
begin

reset <= not joyd;
dir <= joyl & joyr;
shiftreg: entity work.shift_reg(arch)
	port map(
		input => switch,
		output => led,
		dir => dir,
		load => joyu,
		reset => reset,
		clk => clk
	);

end arch;