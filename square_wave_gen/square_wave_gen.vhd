library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity square_wave_gen is
	port(
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		--onp: in  STD_LOGIC_VECTOR (3 downto 0);
		--offp : in  STD_LOGIC_VECTOR (3 downto 0);
		level : out  STD_LOGIC
	);
end square_wave_gen;

architecture arch of square_wave_gen is
	constant CLOCK_DIVIDER: integer := 10; -- 100Mhz clk * 10 == 100ns
	signal clock_divide_counter : integer range 0 to CLOCK_DIVIDER-1 := 0;
	signal one_pulse : std_logic := '0';
	constant DUTY: integer := 4; -- fixed duty cycle of 4 cycles
	signal duty_counter: integer range 0 to DUTY-1 := 0;
	signal output : std_logic := '0';
begin

-- 100ns pulse generator
process (clk)
begin
	if rising_edge(clk) then
		if (rst='1') then
			clock_divide_counter <= 0;
		else
			if (clock_divide_counter = CLOCK_DIVIDER - 1) then
				clock_divide_counter <= 0;
				one_pulse <= '1';
			else
				clock_divide_counter <= clock_divide_counter + 1;
				one_pulse <= '0';
			end if;
		end if;
	end if;
end process;	

process (clk)
begin
    if rising_edge(clk) then
        if (rst='1') then
            duty_counter <= 0;
				output <= '0';
        elsif (one_pulse = '1') then
            if (duty_counter = DUTY-1) then
                duty_counter <= 0;
					 output <= not output;
            else
               duty_counter <= duty_counter+1;
            end if;
        end if;
    end if;
end process;

level <= output;
end arch;



architecture pong of square_wave_gen is
	constant DSVR: integer := 10; -- 100Mhz clk * 10 == 100ns
	constant DUTY: integer := 4; -- fixed duty cycle of 4 cycles
	--constant DSVR: integer := 2500000; -- 25Mhz clk	
	signal ms_reg, ms_next: unsigned(3 downto 0);
	signal cnt_reg, cnt_next: unsigned(2 downto 0);
	signal dir_reg, dir_next: std_logic;
	signal ms_tick, cnt_tick: std_logic;
begin

	process(clk)
	begin
		if (rising_edge(clk)) then
			ms_reg <= ms_next;
			cnt_reg <= cnt_next;
			dir_reg <= dir_next;
		end if;
	end process;

	-- 100nsec tick generator
	ms_next <=
		(others => '0') 	when rst='1' or ms_reg=DSVR else
		ms_reg + 1;
	ms_tick <= '1' 		when ms_reg=DSVR else '0';
	
	-- duty / threshold counter
	cnt_next <=
		(others => '0') 	when rst='1' or cnt_reg=DUTY else
		cnt_reg + 1			when ms_tick='1' else
		cnt_reg;
	cnt_tick <= '1' 		when cnt_reg=DUTY else '0';
	
	-- output level selector
	dir_next <=
		'1'					when rst='1' else
		'1'					when (cnt_tick='1' and dir_reg='0') else
		'0'					when (cnt_tick='1' and dir_reg='1') else
		dir_reg;
	
	level <= dir_reg;
end pong;