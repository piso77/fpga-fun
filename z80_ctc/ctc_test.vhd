library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ctc_test is
	Port (
			clk			: in  STD_LOGIC;
			dir_up		: in  STD_LOGIC;
			switch		: in  STD_LOGIC_VECTOR(7 downto 0);
			led			: out  STD_LOGIC_VECTOR(7 downto 0)
		);
end ctc_test;

architecture Behavioral of ctc_test is
	signal trgs : std_logic_vector(3 downto 0);
begin

	trgs <= "000" & not dir_up;

	ctc0: entity work.ctc_top
	port map(
		clk => clk,
		n_ce => '0',
		n_rd => '0',
		n_wr => '0',
		cs => "00",
		clk_trg => trgs,
		zc_to => "0000",
		dbus_in => switch,
		dbus_out => led
	);
end Behavioral;

