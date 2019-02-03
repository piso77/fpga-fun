LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
entity pseudorng_tb IS
end pseudorng_tb;
 
architecture behavior of pseudorng_tb is 

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal en : std_logic := '0';

 	--Outputs
   signal q : std_logic_vector(7 downto 0);
   signal check : std_logic;

   -- Clock period definitions
   constant clock_period : time := 100 ns;

begin

	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.pseudorng(arch) PORT MAP (
          clk => clk,
          reset => reset,
          en => en,
          q => q,
          check => check
        );

   -- Clock process definitions
   clock_process :process
   begin
		clk <= '0';
		wait for clock_period/2;
		clk <= '1';
		wait for clock_period/2;
   end process;


   -- Stimulus process
   stim_proc: process
   begin		
	reset <= '0';
   en <= '1';
   wait for 1000 ns;
   end process;

end;