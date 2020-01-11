library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ctc is
	Port (
			clk 			: in  STD_LOGIC;
			rst 			: in  STD_LOGIC;
			n_rd			: in  STD_LOGIC;
			n_wr			: in  STD_LOGIC;
			clk_trg			: in  STD_LOGIC;
			zc_to			: out STD_LOGIC;
			dbus_in 		: in  STD_LOGIC_VECTOR(7 downto 0);
			dbus_out 		: out STD_LOGIC_VECTOR(7 downto 0)
		);
end ctc;

architecture Behavioral of ctc is
	type states is (setctrl, settime);
	signal state		: states := setctrl;
--	signal nextstate	: states := setctrl;
	type cntwork is (halt, twait, timer, cdown);
	signal mode			: cntwork := halt;
	signal startup		: boolean := false;

	signal ctrlword		: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal timeword		: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

	constant VECCTRL	: natural := 0; -- 0/1: interrupt vector/ctrl word
	constant TCFOLLOW	: natural := 2;
	constant TTRIGGER	: natural := 3;
	constant PSCALER	: natural := 5;
	constant TMODE		: natural := 6; -- 0/1: timer/down-counter
begin

	-- cpu / internal logic
	process(clk, rst)
	begin
		if rst='1' then
			state <= setctrl;
			startup <= false;
			ctrlword <= (others => '0');
			timeword <= (others => '0');
		elsif rising_edge(clk) then
			if n_wr='0' then
				if state=setctrl then
					startup <= false;
					ctrlword <= dbus_in;
					if dbus_in(TCFOLLOW)='1' then
						state <= settime;
					end if;
				elsif state=settime then
					state <= setctrl;
					timeword <= dbus_in;
					startup <= true;
				end if;
			end if;
		end if;
	end process;

	-- counter logic
	process(clk, startup, timeword)
		variable downcnt : natural range 0 to 256; 
	begin
		if startup=true then
			downcnt := to_integer(unsigned(timeword));
			mode <= cdown;
		elsif rising_edge(clk) then
			if mode=cdown then
				downcnt := downcnt-1;
				if downcnt=0 then
					zc_to <= '1';
					mode <= halt;
				end if;
			end if;
		end if;
	end process;

	dbus_out <= ctrlword when n_rd='0' and clk_trg='0' else
				timeword when n_rd='0' and clk_trg='1' else
				(others => 'Z');
end Behavioral;
