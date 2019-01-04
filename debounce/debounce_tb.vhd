LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY debounce_tb IS
END debounce_tb;
 
ARCHITECTURE behavior OF debounce_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT debounce
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         sw : IN  std_logic;
         db : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal sw : std_logic := '0';

 	--Outputs
   signal db : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.debounce(delayed) PORT MAP (
          clk => clk,
          rst => rst,
          sw => sw,
          db => db
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
		rst <= '1';
		sw <= '1';
      wait for 1 ms;
		rst <= '0';
		wait for 40 ms;
		sw <= '0';
      wait for 40ms;
		sw <= '1';
		wait for 10ms;
		sw <= '0';
		
   end process;

END;
