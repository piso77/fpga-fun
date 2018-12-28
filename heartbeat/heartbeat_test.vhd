library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity heartbeat_test is
   port(
		clk : in  STD_LOGIC;
		switch : in  STD_LOGIC;
		an : out  STD_LOGIC_VECTOR (3 downto 0);
		sseg : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end heartbeat_test;

architecture arch of heartbeat_test is
	signal d0, d1, d2, d3: std_logic_vector(7 downto 0);
begin

hb: entity work.heartbeat(arch)
	port map(
		clk => clk,
		en => switch,
		out0 => d0,
		out1 => d1,
		out2 => d2,
		out3 => d3		
	);

dm: entity work.disp_mux(arch)
	port map(
		clk => clk,
		reset => '0',
		in0 => d0,
		in1 => d1,
		in2 => d2,
		in3 => d3,		
		an => an,
		sseg => sseg
	);
	
end arch;

