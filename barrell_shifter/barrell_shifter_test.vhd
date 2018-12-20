----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:07:28 12/19/2018 
-- Design Name: 
-- Module Name:    barrell_shifter_test - arch 
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

entity barrell_shifter_test is
   port(
		switch : in  STD_LOGIC_VECTOR (7 downto 0);
      btn : in  STD_LOGIC_VECTOR (2 downto 0);
      led : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end barrell_shifter_test;

architecture arch of barrell_shifter_test is
	signal tmp: STD_LOGIC_VECTOR(2 downto 0);
begin

tmp <= not btn;

shifter: entity work.barrell_shifter(sel_arch)
	port map(
		a => switch,
		amt => tmp,
		y => led
	);

end arch;