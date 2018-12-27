library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity square_wave_gen is
	port(
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		onp : in  STD_LOGIC_VECTOR (3 downto 0);
		offp : in  STD_LOGIC_VECTOR (3 downto 0);
		level : out  STD_LOGIC
	);
end square_wave_gen;

architecture arch of square_wave_gen is
	constant CLOCK_DIVIDER: integer := 10; -- 100Mhz clk * 10 == 100ns
	signal clock_divide_counter : integer range 0 to CLOCK_DIVIDER-1 := 0;
	signal one_pulse : std_logic := '0';
	--constant onperiod: integer := 4; -- fixed duty cycle of 4 cycles
	--signal period_counter: integer range 0 to DUTY-1 := 0;
	signal onperiod, offperiod: integer;
	signal period_counter: integer;
	signal output : std_logic;
begin

onperiod <= to_integer(unsigned(onp));
offperiod <= to_integer(unsigned(offp));

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
            period_counter <= 0;
				output <= '1';
        elsif (one_pulse = '1') then
				if (output='1') then
					if (period_counter = onperiod-1) then
						 period_counter <= 0;
						 output <= '0';
					else
						period_counter <= period_counter+1;
					end if;
				else -- (output='0')
					if (period_counter = offperiod-1) then
						 period_counter <= 0;
						 output <= '1';
					else
						period_counter <= period_counter+1;
					end if;
				end if;
        end if;
    end if;
end process;

level <= output;
end arch;



architecture chu of square_wave_gen is
	constant CLOCK_DIVIDER: integer := 10; -- 100Mhz clk * 10 == 100ns
	signal clock_divide_counter : integer range 0 to CLOCK_DIVIDER-1 := 0;
	signal one_pulse : std_logic := '0';
	signal onperiod, offperiod: integer;
	signal period_counter_reg, period_counter_next: integer;
	signal output_reg, output_next : std_logic;
begin

onperiod <= to_integer(unsigned(onp));
offperiod <= to_integer(unsigned(offp));

process(clk, rst)
begin
	if rising_edge(clk) then
		if (rst='1') then
			output_reg <= '0';
			period_counter_reg <= 0;
		else
			output_reg <= output_next;
			period_counter_reg <= period_counter_next;
		end if;
	end if;
end process;

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

process (one_pulse, output_reg, period_counter_reg, onperiod, offperiod)
begin
	period_counter_next <= period_counter_reg;
	output_next <= output_reg;
	if (one_pulse = '1') then
		if (output_reg='1') then
			if (period_counter_reg = onperiod-1) then
				 period_counter_next <= 0;
				 output_next <= '0';
			else
				period_counter_next <= period_counter_reg+1;
				output_next <= output_reg;
			end if;
		else -- (output_reg='0')
			if (period_counter_reg = offperiod-1) then
				 period_counter_next <= 0;
				 output_next <= '1';
			else
				period_counter_next <= period_counter_reg+1;
				output_next <= output_reg;
			end if;
		end if;
	end if;
end process;

level <= output_reg;
end chu;