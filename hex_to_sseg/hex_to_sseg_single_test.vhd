----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:08:58 12/18/2018 
-- Design Name: 
-- Module Name:    hex_to_sseg_single_test - Behavioral 
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

entity hex_to_sseg_single_test is
	port(
		switch : in  STD_LOGIC_VECTOR (3 downto 0);
      an : out  STD_LOGIC_VECTOR (3 downto 0);
      sseg : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end hex_to_sseg_single_test;

architecture arch of hex_to_sseg_single_test is
begin


end arch;

