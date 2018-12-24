library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity stop_watch is
	port(
		clk : in  STD_LOGIC;
		go : in  STD_LOGIC;
		clr : in  STD_LOGIC;
		d0 : out  STD_LOGIC_VECTOR (3 downto 0);
		d1 : out  STD_LOGIC_VECTOR (3 downto 0);
		d2 : out  STD_LOGIC_VECTOR (3 downto 0)
	);
end stop_watch;

architecture cascade_arch of stop_watch is
	--constant DSVR: integer := 10000000; -- 100Mhz clk
	constant DSVR: integer := 2500000; -- 25Mhz clk	
	signal ms_reg, ms_next: unsigned(21 downto 0);
	signal d0_reg, d0_next: unsigned(3 downto 0);
	signal d1_reg, d1_next: unsigned(3 downto 0);
	signal d2_reg, d2_next: unsigned(3 downto 0);
	signal ms_tick, d0_tick, d1_tick: std_logic;
	signal d0_en, d1_en, d2_en: std_logic;
begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			ms_reg <= ms_next;
			d0_reg <= d0_next;
			d1_reg <= d1_next;
			d2_reg <= d2_next;
		end if;
	end process;
	
	-- 0.1 sec tick generator: mod-10000000
	ms_next <=
		(others => '0') 	when clr='1' or (ms_reg=DSVR and go='1') else
		ms_reg + 1			when go='1' else
		ms_reg;
	ms_tick <= '1' 		when ms_reg=DSVR else '0';

	-- 0.1 sec counter
	d0_en <= '1' 			when ms_tick='1' else '0';
	d0_next <=
		(others => '0') 	when clr='1' or (d0_reg=9 and d0_en='1') else
		d0_reg + 1			when d0_en='1' else
		d0_reg;
	d0_tick <= '1' 		when d0_reg=9 else '0';

	-- 1 sec counter
	d1_en <= '1' 			when d0_tick='1' and ms_tick='1' else '0';
	d1_next <=
		(others => '0') 	when clr='1' or (d1_reg=9 and d1_en='1') else
		d1_reg + 1			when d1_en='1' else
		d1_reg;
	d1_tick <= '1' 		when d1_reg=9 else '0';

	-- 10 sec counter
	d2_en <= '1' 			when d1_tick='1' and d0_tick='1' and ms_tick='1' else '0';
	d2_next <=
		(others => '0') 	when clr='1' or (d2_reg=9 and d2_en='1') else
		d2_reg + 1			when d2_en='1' else
		d2_reg;

	-- output
	d0 <= std_logic_vector(d0_reg);
	d1 <= std_logic_vector(d1_reg);
	d2 <= std_logic_vector(d2_reg);

end cascade_arch;

architecture if_arch of stop_watch is
	--constant DSVR: integer := 10000000; -- 100Mhz clk
	constant DSVR: integer := 2500000; -- 25Mhz clk
	signal ms_reg, ms_next: unsigned(21 downto 0);
	signal d0_reg, d0_next: unsigned(3 downto 0);
	signal d1_reg, d1_next: unsigned(3 downto 0);
	signal d2_reg, d2_next: unsigned(3 downto 0);
	signal ms_tick: std_logic;
begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			ms_reg <= ms_next;
			d0_reg <= d0_next;
			d1_reg <= d1_next;
			d2_reg <= d2_next;
		end if;
	end process;

	-- 0.1 sec tick generator: mod-10000000
	ms_next <=
		(others => '0') 	when clr='1' or (ms_reg=DSVR and go='1') else
		ms_reg + 1			when go='1' else
		ms_reg;
	ms_tick <= '1' 		when ms_reg=DSVR else '0';

	process(clr, ms_tick, d0_reg, d1_reg, d2_reg)
	begin
		d0_next <= d0_reg;
		d1_next <= d1_reg;
		d2_next <= d2_reg;
		if clr='1' then
			d0_next <= "0000";
			d1_next <= "0000";
			d2_next <= "0000";
		elsif ms_tick='1' then
			if (d0_reg/=9) then
				d0_next <= d0_reg + 1;
			else -- reach XX9
				d0_next <= "0000";
				if (d1_reg/=9) then
					d1_next <= d1_reg + 1;
				else -- reach X99
					d1_next <= "0000";
					if (d2_reg/=9) then
						d2_next <= d2_reg + 1;
					else
						d2_next <= "0000";
					end if;
				end if;
			end if;
		end if;
	end process;

	-- output
	d0 <= std_logic_vector(d0_reg);
	d1 <= std_logic_vector(d1_reg);
	d2 <= std_logic_vector(d2_reg);

end if_arch;