library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
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
	signal nextstate	: states := setctrl;
	type work is (halt, twait, timer, cdown);
	signal mode			: work := halt;
	signal initcnt		: boolean := false;

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
			initcnt <= false;
			ctrlword <= (others => '0');
			timeword <= (others => '0');
		elsif rising_edge(clk) then
			if n_wr='0' then
				if state=setctrl then
					if dbus_in(VECCTRL)='1' then
						initcnt <= false;
						ctrlword <= dbus_in;
						if dbus_in(TCFOLLOW)='1' then
							nextstate <= settime;
						end if;
					end if; -- XXX int vector?
				elsif state=settime then
					nextstate <= setctrl;
					timeword <= dbus_in;
					initcnt <= true;
				end if;
			else
				state <= nextstate;
			end if;
		end if;
	end process;

	-- counter logic
	process(clk, initcnt)
		variable downcnt : natural range 0 to 256; 
	begin
		zc_to <= '0';
		if mode/=halt then
			if rising_edge(clk) then
				if mode=cdown and clk_trg='1' then
					downcnt := downcnt-1;
				elsif mode=timer then
					downcnt := downcnt-1;	-- XXX scaler
				end if;
				if downcnt=0 then
					zc_to <= '1';
					-- XXX output int vector?
				end if;
			end if;
		elsif initcnt=true then
			if timeword=x"00" then
				downcnt := 256;
			else
				downcnt := to_integer(unsigned(dbus_in));
			end if;
			if ctrlword(TMODE)='0' then		-- timer mode
				if ctrlword(TTRIGGER)='0' then
					mode <= timer;
				else
					mode <= twait;
				end if;
			else							-- countdown mode
				mode <= cdown;
			end if;
		end if;
	end process;

	dbus_out <= ctrlword when n_rd='0' and clk_trg='0' else
				timeword when n_rd='0' and clk_trg='1' else
				(others => 'Z');
end Behavioral;
