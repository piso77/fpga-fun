library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ctc_top is
	Port (
			clk 			: in  STD_LOGIC;
			n_ce			: in  STD_LOGIC;
			n_rd			: in  STD_LOGIC;
			n_wr			: in  STD_LOGIC;
			cs				: in  STD_LOGIC_VECTOR(1 downto 0);
			clk_trg			: in  STD_LOGIC_VECTOR(3 downto 0);
			zc_to			: out STD_LOGIC_VECTOR(3 downto 0);
			dbus_in 		: in  STD_LOGIC_VECTOR(7 downto 0);
			dbus_out 		: out  STD_LOGIC_VECTOR(7 downto 0)
		);
end ctc_top;

architecture Behavioral of ctc_top is
	signal chan		: STD_LOGIC_VECTOR(3 downto 0) := (others => '1');
	signal en_rd	: STD_LOGIC_VECTOR(3 downto 0) := (others => '1');
	signal en_wr	: STD_LOGIC_VECTOR(3 downto 0) := (others => '1');
begin
	chan <= "1110" when cs="00" else
			"1101" when cs="01" else
			"1011" when cs="10" else
			"0111";

	en_rd(0) <= n_ce or n_rd or chan(0);
	en_wr(0) <= n_ce or n_wr or chan(0);
	ctc0: entity work.ctc
	port map(
		clk => clk,
		rst => '0',
		n_rd => en_rd(0),
		n_wr => en_wr(0),
		clk_trg => clk_trg(0),
		zc_to => zc_to(0),
		dbus_in => dbus_in,
		dbus_out => dbus_out
	);
end Behavioral;
