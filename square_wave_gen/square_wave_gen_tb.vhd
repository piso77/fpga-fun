LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY square_wave_gen_tb IS
END square_wave_gen_tb;
 
ARCHITECTURE behavior OF square_wave_gen_tb IS 
   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
	signal onp : std_logic_vector(3 downto 0) := "0000";
	signal offp : std_logic_vector(3 downto 0) := "0000";
	
 	--Outputs
   signal level : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.square_wave_gen(chu) PORT MAP (
          clk => clk,
          rst => rst,
			 onp => onp,
			 offp => offp,
          level => level
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rst <= '1';
      wait for 100 ns;
		rst <= '0';
		onp <= "0010";
		offp <= "0001";
      
      wait;
   end process;

END;
