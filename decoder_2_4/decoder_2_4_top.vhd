----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:52:45 12/18/2018 
-- Design Name: 
-- Module Name:    decoder_2_4_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder_2_4_top is
    port(
		switch : in  STD_LOGIC_VECTOR (1 downto 0);
		en : in STD_LOGIC;
		led : out  STD_LOGIC_VECTOR (3 downto 0)
	 );
end decoder_2_4_top;

architecture Behavioral of decoder_2_4_top is
begin
decode: entity work.decoder_2_4(case_arch)
		  port map(
		  a => switch,
		  en => en,
		  y => led
		  );
end Behavioral;

