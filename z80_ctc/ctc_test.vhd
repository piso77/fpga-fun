library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ctc_test is
	Port (
			clk			: in  STD_LOGIC;
			dir_up		: in  STD_LOGIC;
			sw		: in  STD_LOGIC_VECTOR(7 downto 0);
			led			: out  STD_LOGIC_VECTOR(7 downto 0)
		);
end ctc_test;

architecture Behavioral of ctc_test is
	signal trgs : std_logic_vector(3 downto 0);
	signal downclk : std_logic_vector(23 downto 0) := (others => '0');
	signal pulse : std_logic;
begin

	process(clk)
	begin
		if rising_edge(clk) then
			downclk <= std_logic_vector(unsigned(downclk)+1);
		end if;
	end process;
	pulse <= downclk(23);

	trgs <= "000" & not dir_up;

	ctc0: entity work.ctc_top
	port map(
		clk => pulse,
		n_ce => '0',
		n_rd => '0',
		n_wr => '0',
		cs => "00",
		clk_trg => trgs,
		--zc_to => "0000",
		dbus_in => sw,
		dbus_out => led
	);
end Behavioral;
