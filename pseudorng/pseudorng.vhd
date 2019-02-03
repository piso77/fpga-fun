library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pseudorng is
	Port(
		clk	: in 	STD_LOGIC;
		reset : in 	STD_LOGIC;
		en 	: in 	STD_LOGIC;
		q 		: out STD_LOGIC_VECTOR (7 downto 0);
		check	: out STD_LOGIC
	);
end pseudorng;

-- https://stackoverflow.com/questions/43081067/pseudo-random-number-generator-using-lfsr-in-vhdl
architecture arch of pseudorng is
signal qtmp: STD_LOGIC_VECTOR(7 downto 0) := x"01";

begin

process(clk)
variable scratch : STD_LOGIC := '0';
begin

if rising_edge(clk) then
   if (reset='1') then
   -- credit to QuantumRipple for pointing out that this should not
   -- be reset to all 0's, as you will enter an invalid state
      qtmp <= x"01"; 
   elsif en = '1' then
      scratch := qtmp(4) xor qtmp(3) xor qtmp(2) xor qtmp(0);
      qtmp <= scratch & qtmp(7 downto 1);
   end if;
end if;

end process;

-- check <= temp;
check <= qtmp(7);
q <= qtmp;
end arch;