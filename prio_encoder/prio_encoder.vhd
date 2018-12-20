----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:37:40 12/18/2018 
-- Design Name: 
-- Module Name:    prio_encoder - cond_arch 
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

entity prio_encoder is
	port(
		r : in  STD_LOGIC_VECTOR (4 downto 1);
		pcode : out  STD_LOGIC_VECTOR (2 downto 0)
	);
end prio_encoder;

architecture cond_arch of prio_encoder is
begin
	pcode <= "100" when (r(4) = '1') else
				"011" when (r(3) = '1') else
				"010" when (r(2) = '1') else
				"001" when (r(1) = '1') else
				"000";
end cond_arch;

architecture sel_arch of prio_encoder is
begin
	with r select
		pcode <= "100" when "1000"|"1001"|"1010"|"1011"|
								  "1100"|"1101"|"1110"|"1111",
					"011" when "0100"|"0101"|"0110"|"0111",
					"010" when "0010"|"0011",
					"001" when "0001",
					"000" when others;
end sel_arch;

architecture if_arch of prio_encoder is
begin
	process(r)
	begin
		if (r(4) = '1') then
			pcode <= "100";
		elsif (r(3) = '1') then
			pcode <= "011";
		elsif (r(2) = '1') then
			pcode <= "010";
		elsif (r(1) = '1') then
			pcode <= "001";
		else 
			pcode <= "000";
		end if;
	end process;
end if_arch;

architecture case_arch of prio_encoder is
begin
	process(r)
	begin
		case r is
			when "1000"|"1001"|"1010"|"1011"|
				  "1100"|"1101"|"1110"|"1111" =>
				pcode <= "100";
			when "0100"|"0101"|"0110"|"0111" =>
				pcode <= "011";
			when "0010"|"0011" =>
				pcode <= "010";
			when "0001" =>
				pcode <= "001";
			when others =>
				pcode <= "000";
		end case;
	end process;
end case_arch;