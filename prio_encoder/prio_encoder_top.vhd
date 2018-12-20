----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:33:38 12/18/2018 
-- Design Name: 
-- Module Name:    prio_encoder - Behavioral 
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

entity prio_encoder_top is
	Port(
		switch : in  STD_LOGIC_VECTOR (3 downto 0);
		led : out  STD_LOGIC_VECTOR (2 downto 0)
	);
end prio_encoder_top;

architecture Behavioral of prio_encoder_top is
begin
prio_enc:
	entity work.prio_encoder(sel_arch)
	port map(
		r => switch,
		pcode => led
	);
end Behavioral;

