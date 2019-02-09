
-- VHDL Instantiation Created from source file disp_hex_mux.vhd -- 19:25:07 02/09/2019
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT disp_hex_mux
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		hex0 : IN std_logic_vector(3 downto 0);
		hex1 : IN std_logic_vector(3 downto 0);
		hex2 : IN std_logic_vector(3 downto 0);
		hex3 : IN std_logic_vector(3 downto 0);
		dp_in : IN std_logic_vector(3 downto 0);          
		an : OUT std_logic_vector(3 downto 0);
		sseg : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	Inst_disp_hex_mux: disp_hex_mux PORT MAP(
		clk => ,
		reset => ,
		hex0 => ,
		hex1 => ,
		hex2 => ,
		hex3 => ,
		dp_in => ,
		an => ,
		sseg => 
	);


