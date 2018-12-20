----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:38:15 12/18/2018 
-- Design Name: 
-- Module Name:    add_w_carry - arch 
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

entity add_w_carry is
	generic(N: integer := 4);
	port(
		a, b: in std_logic_vector(N-1 downto 0);
		cout: out std_logic;
		sum: out std_logic_vector(N-1 downto 0) 
	);
end add_w_carry;

architecture arch of add_w_carry is
	signal a_ext, b_ext, sum_ext: unsigned(N downto 0);
begin
	a_ext <= unsigned('0' & a);
	b_ext <= unsigned('0' & b);
	sum_ext <= a_ext + b_ext;
	sum <= std_logic_vector(sum_ext(N-1 downto 0));
	cout <= sum_ext(N);
end arch;

