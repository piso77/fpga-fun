library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- necessary for the logic implementation
USE ieee.std_logic_unsigned.all;

entity debounce is
	generic(
		counter_size  :  INTEGER := 19 --counter size (19 bits gives 10.5ms with 50MHz clock)
	); 
	port(
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		sw : in  STD_LOGIC;
		db : out  STD_LOGIC
	);
end debounce;

architecture upfront of debounce is
	constant N: integer := 11; -- 2^N * 10ns = 20ms tick -- 100Mhz clk
	signal cnt_reg, cnt_next: unsigned(N-1 downto 0);
	signal cnt_load, cnt_add: std_logic;
	signal tick: std_logic;
	type state_type is (zero, wait1_1, one, wait0_1);
	signal state_reg, state_next: state_type;
begin
	
	process(clk, rst)
	begin
		if (rst='1') then
			state_reg <= zero;
			cnt_reg <= (others => '0');
		elsif rising_edge(clk) then
			state_reg <= state_next;
			cnt_reg <= cnt_next;
		end if;
	end process;
	
	
	cnt_next <= (others => '0') when cnt_load='1' else
					cnt_reg + 1 when cnt_add='1' else
					cnt_reg;
	
	tick <= '1' when cnt_reg="11111111111" else '0';
	
	process(state_reg, sw, tick)
	begin
		state_next <= state_reg;
		cnt_load <= '0';
		cnt_add <= '0';
		db <= '0';
		
		case state_reg is
			when zero =>
				if sw='1' then
					db <= '1';
					cnt_load <= '1';
					state_next <= wait1_1;
				end if;
			when wait1_1 =>
				db <= '1';
				cnt_add <= '1';
				if tick='1' then
					if sw='1' then
						state_next <= one;
					else -- bounced back to 0
						db <= '0';
						state_next <= zero;
					end if;
				end if;
			when one =>
				db <= '1';
				if sw='0' then
					db <= '0';
					cnt_load <= '1';
					state_next <= wait0_1;					
				end if;
			when wait0_1 =>
				db <= '0';
				cnt_add <= '1';
					if sw='0' then
						state_next <= zero;
					else -- bounced back to 0
						db <= '1';
						state_next <= one;
					end if;
		end case;
	end process;
	
end upfront;

architecture delayed of debounce is
	constant N: integer := 10; -- 2^N * 10ns = 10ms tick -- 100Mhz clk
	signal cnt_reg, cnt_next: unsigned(N-1 downto 0);
	signal tick: std_logic;
	type state_type is (zero, wait1_1, wait1_2, wait1_3, one, wait0_1, wait0_2, wait0_3);
	signal state_reg, state_next: state_type;
begin

process(clk, rst)
begin
	if rst='1' then
		cnt_reg <= (others => '0');
		state_reg <= zero;
	elsif rising_edge(clk) then
		cnt_reg <= cnt_next;
		state_reg <= state_next;
	end if;
end process;

cnt_next <= cnt_reg+1;
tick <= '1' when cnt_reg = 0 else '0';

process(state_reg, sw, tick)
begin
	state_next <= state_reg;
	db <= '0';
	case state_reg is
		when zero =>
			if sw='1' then
				state_next <= wait1_1;
			end if;
		when wait1_1 =>
			if sw='0' then
				state_next <= zero;
			else -- sw='1'
				if tick='1' then
					state_next <= wait1_2;
				end if;
			end if;
		when wait1_2 =>
			if sw='0' then
				state_next <= zero;
			else -- sw='1'
				if tick='1' then
					state_next <= wait1_3;
				end if;
			end if;
		when wait1_3 =>
			if sw='0' then
				state_next <= zero;
			else -- sw='1'
				if tick='1' then
					state_next <= one;
				end if;
			end if;
		when one =>
			db <= '1';
			if sw='0' then
				state_next <= wait0_1;
			end if;
		when wait0_1 =>
			db <= '1';
			if sw='1' then
				state_next <= one;
			else -- sw='0'
				if tick='1' then
					state_next <= wait0_2;
				end if;
			end if;
		when wait0_2 =>
			db <= '1';
			if sw='1' then
				state_next <= one;
			else -- sw='0'
				if tick='1' then
					state_next <= wait0_3;
				end if;
			end if;
		when wait0_3 =>
			db <= '1';
			if sw='1' then
				state_next <= one;
			else -- sw='0'
				if tick='1' then
					state_next <= zero;
				end if;
			end if;
	end case;
end process;

end delayed;

-- https://www.digikey.com/eewiki/pages/viewpage.action?pageId=4980758 - first example
ARCHITECTURE logic OF debounce IS
  SIGNAL flipflops   : STD_LOGIC_VECTOR(1 DOWNTO 0); --input flip flops
  SIGNAL counter_set : STD_LOGIC;                    --sync reset to zero
  SIGNAL counter_out : STD_LOGIC_VECTOR(counter_size DOWNTO 0) := (OTHERS => '0'); --counter output
BEGIN

  counter_set <= flipflops(0) xor flipflops(1);   --determine when to start/reset counter
  
  PROCESS(clk, rst)
  BEGIN
	 IF (rst='1') then
		flipflops <= (OTHERS => '0');
    ELSIF(clk'EVENT and clk = '1') THEN
      flipflops(0) <= sw;
      flipflops(1) <= flipflops(0);
      If(counter_set = '1') THEN                  --reset counter because input is changing
        counter_out <= (OTHERS => '0');
      ELSIF(counter_out(counter_size) = '0') THEN --stable input time is not yet met
        counter_out <= counter_out + 1;
      ELSE                                        --stable input time is met
        db <= flipflops(1);
      END IF;    
    END IF;
  END PROCESS;
END logic;

-- https://www.digikey.com/eewiki/pages/viewpage.action?pageId=4980758 - second example
architecture microsemi of DeBounce is
    constant N              : integer := 21;   -- 2^20 * 1/(33MHz) = 32ms
    signal q_reg, q_next    : unsigned(N-1 downto 0);
    signal DFF1, DFF2       : std_logic;
    signal q_reset, q_add   : std_logic;
	 signal DB_out				 : std_logic;
begin

    -- COUNTER FOR TIMING 
    q_next <= (others => '0') when q_reset = '1' else  -- resets the counter 
                    q_reg + 1 when q_add = '1' else    -- increment count if commanded
                    q_reg;  

    -- SYNCHRO REG UPDATE
    process(clk, rst)
    begin
        if(rising_edge(clk)) then
            if(rst = '0') then
                q_reg <= (others => '0');   -- reset counter
            else
                q_reg <= q_next;            -- update counter reg
            end if;
        end if;
    end process;

    -- Flip Flop Inputs
    process(clk, sw)
    begin
        
        if(rising_edge(clk)) then
            if(rst = '0') then
                DFF1 <= '0';
                DFF2 <= '0';
            else
                DFF1 <= sw;
                DFF2 <= DFF1;
            end if;
        end if;
    end process;
    q_reset <= DFF1 xor DFF2;           -- if DFF1 and DFF2 are different q_reset <= '1';

    -- Counter Control Based on MSB of counter, q_reg
    process(clk, q_reg, db_out)
    begin
        
        if(rising_edge(clk)) then
            q_add <= not(q_reg(N-1));        -- enables the counter whe msb is not '1'
            if(q_reg(N-1) = '1') then
                DB_out <= DFF2;
            else
                DB_out <= DB_out;
            end if;
        end if;

    end process;
	 
	 db <= db_out;
	 
end microsemi;