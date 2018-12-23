LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY univ_bin_counter_tb IS
END univ_bin_counter_tb;
 
ARCHITECTURE arch OF univ_bin_counter_tb IS 
   constant THREE		: integer	:= 3;
	constant T			: time		:= 10 ns;
   signal clk			: std_logic;
   signal reset		: std_logic;
   signal sync_clr 	: std_logic;
   signal load 		: std_logic;
   signal en 			: std_logic;
   signal up 			: std_logic;
   signal d 			: std_logic_vector(THREE-1 downto 0);

   signal max_tick : std_logic;
   signal min_tick : std_logic;
   signal q : std_logic_vector(THREE-1 downto 0);
 
BEGIN
   uut: entity work.univ_bin_counter(arch)
		generic map(N => THREE)
		port map (
          clk => clk,
          reset => reset,
          sync_clr => sync_clr,
          load => load,
          en => en,
          up => up,
          d => d,
          max_tick => max_tick,
          min_tick => min_tick,
          q => q
      );

	-- 10 ns clock period
   process
   begin
		clk <= '0';
		wait for T / 2;
		clk <= '1';
		wait for T / 2;
   end process;

	-- initial reset asserted to T / 2
	reset <= '1', '0' after T / 2;

   process
   begin
		-- initial input
		sync_clr <= '0';
		load		<= '0';
		en			<= '0';
		up			<= '1';
		d			<= (others => '0');
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		
		-- test load
		load		<= '1';
		d			<= "011";
		wait until falling_edge(clk);
		
		load 		<= '0';
		wait until falling_edge(clk);
		wait until falling_edge(clk);

		-- test sync_clear
		sync_clr	<= '1';
		wait until falling_edge(clk);
		sync_clr	<= '0';
		
		-- test up counter and pause
		en			<= '1';
		up			<= '1';
		for i in 1 to 10 loop
			wait until falling_edge(clk);
		end loop;
		en <= '0';
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		en <= '1';
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		
		-- test down counter
		up <= '0';
		for i in 1 to 10 loop
			wait until falling_edge(clk);
		end loop;

		-- other wait conditions
		-- continue until q=2
		wait until q="010";
		wait until falling_edge(clk);
		up <= '1';
		-- continue until min_tick changes value
		wait on min_tick;
		wait until falling_edge(clk);
		up <= '0';
		wait for 4 * T;
		en <= '0';
		wait for 4 * T;
		
		-- terminate simulation
		assert false
			report "Simulation completed"
			severity failure;
   end process;
END;