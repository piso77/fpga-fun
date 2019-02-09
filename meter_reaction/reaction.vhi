
-- VHDL Instantiation Created from source file reaction.vhd -- 19:17:18 02/09/2019
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT reaction
	PORT(
		clk : IN std_logic;
		clear : IN std_logic;
		start : IN std_logic;
		stop : IN std_logic;          
		error : OUT std_logic;
		ready : OUT std_logic;
		led : OUT std_logic;
		delay : OUT std_logic_vector(9 downto 0)
		);
	END COMPONENT;

	Inst_reaction: reaction PORT MAP(
		clk => ,
		clear => ,
		start => ,
		stop => ,
		error => ,
		ready => ,
		led => ,
		delay => 
	);


