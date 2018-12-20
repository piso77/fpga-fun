----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:18:52 12/17/2018 
-- Design Name: 
-- Module Name:    test - Behavioral 
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

entity test is
	generic(WIDTH: integer := 8);
	port(
		switch : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		led : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0)
	);
end test;

architecture arch of test is
begin

for_loop:
for i in 0 to (WIDTH-1) generate
	led(i) <= switch(i);
end generate;

end arch;

