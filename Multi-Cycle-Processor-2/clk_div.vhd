----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/31/2019 02:20:50 PM
-- Design Name: 
-- Module Name: Top_Module - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_div is
   port(
   Clock: in std_logic;
   clk_debounce : out std_logic
   );
 end clk_div;
 
 architecture Behavioral of clk_div is 
 
 signal count : integer:= 0;
 signal tempOut : std_logic := '0';
 
 begin
 
	process(Clock)
    begin 
 
		if(falling_edge(Clock)) then 
		   
		     if count<500000 then 
			     count <= count + 1;
			 else
			 
			    tempOut <= not tempOut;
				count <= 0;
			 end if;			 
			 
		   end if;
		    
    end process;
  
  clk_debounce <= tempOut;
  
  --clk_debounce <= Clock;
  
end Behavioral;