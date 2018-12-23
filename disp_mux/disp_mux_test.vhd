library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity disp_mux_test is
   port(
		clk : in  STD_LOGIC;
      btn : in  STD_LOGIC_VECTOR (3 downto 0);
      switch : in  STD_LOGIC_VECTOR (7 downto 0);
      an : out  STD_LOGIC_VECTOR (3 downto 0);
		led : out  STD_LOGIC_VECTOR (3 downto 0);
      sseg : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end disp_mux_test;

architecture arch of disp_mux_test is
	signal reg0, reg1, reg2, reg3 : STD_LOGIC_VECTOR (7 downto 0);
	signal tmp : STD_LOGIC_VECTOR (3 downto 0);
begin
	dp: entity work.disp_mux(arch)
	port map(
		clk => clk,
		reset => '0',
		in0 => reg0,
		in1 => reg1,
		in2 => reg2,
		in3 => reg3,
		an => an,
		sseg => sseg
	);

	tmp <= not btn;

	process(clk)
	begin
		led <= "0000";
		if (rising_edge(clk)) then
			if (tmp(3)='1') then
				reg3 <= switch;
				led(3) <= '1';
			end if;
			if (tmp(2)='1') then
				reg2 <= switch;
				led(2) <= '1';
			end if;
			if (tmp(1)='1') then
				reg1 <= switch;
				led(1) <= '1';
			end if;
			if (tmp(0)='1') then
				reg0 <= switch;
				led(0) <= '1';
			end if;
		end if;
	end process;

end arch;