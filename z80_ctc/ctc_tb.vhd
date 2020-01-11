library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ctc_tb is
end ctc_tb;

architecture arch of ctc_tb is
	constant T		: time := 10 ns;
	signal clk		: std_logic;
	signal n_ce		: std_logic;
	signal n_rd		: std_logic;
	signal n_wr		: std_logic;
	signal trg		: std_logic;
	signal trgs		: std_logic_vector(3 downto 0);
	signal zcto		: std_logic_vector(3 downto 0);
	signal sw		: std_logic_vector(7 downto 0);
	signal led		: std_logic_vector(7 downto 0);
begin

	-- 10 ns clock period
   process
   begin
		clk <= '0';
		wait for T / 2;
		clk <= '1';
		wait for T / 2;
   end process;

	trgs <= "000" & trg; 
	ctc0: entity work.ctc_top
	port map(
		clk => clk,
		n_ce => n_ce,
		n_rd => n_rd,
		n_wr => n_wr,
		cs => "00",
		clk_trg => trgs,
		zc_to => zcto,
		dbus_in => sw,
		dbus_out => led
	);

	process
	begin
	-- initial input
	n_ce <= '0';
	n_rd <= '1';
	n_wr <= '0';
	trg <= '0';
	sw <= "00011111"; -- ctrl word
	wait until falling_edge(clk);
	sw <= "11111111"; -- time word
	wait until falling_edge(clk);


	-- terminate simulation
	assert false
	report "Simulation completed"
	severity failure;
	end process;
end arch;
