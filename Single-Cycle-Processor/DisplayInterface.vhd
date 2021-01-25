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


entity DisplayInterface is
    Port ( 
	
	instruction : in std_logic_vector (31 downto 0);
   addr_pm : in std_logic_vector (31 downto 0);
   addr_dm : in std_logic_vector (31 downto 0);
   data_out : in std_logic_vector (31 downto 0);
   data_in : in std_logic_vector (31 downto 0);
   slide_display : in std_logic_vector (5 downto 0);
   
   display_reg0 : in std_logic_vector(31 downto 0);
   display_reg1 : in std_logic_vector(31 downto 0);
   display_reg2 : in std_logic_vector(31 downto 0);
   display_reg3 : in std_logic_vector(31 downto 0);
   display_reg4 : in std_logic_vector(31 downto 0);
   display_reg5 : in std_logic_vector(31 downto 0);
   display_reg6 : in std_logic_vector(31 downto 0);
   display_reg7 : in std_logic_vector(31 downto 0);
   display_reg8 : in std_logic_vector(31 downto 0);
   display_reg9 : in std_logic_vector(31 downto 0);
   display_reg10 : in std_logic_vector(31 downto 0);
   display_reg11 : in std_logic_vector(31 downto 0);
   display_reg12 : in std_logic_vector(31 downto 0);
   display_reg13 : in std_logic_vector(31 downto 0);
   display_reg14 : in std_logic_vector(31 downto 0);
   display_reg15 : in std_logic_vector(31 downto 0);
                                 
   
   
   -- Add the States input from the CPU
   
   led_Out : out std_logic_vector (15 downto 0) 
	
           );
end DisplayInterface;


architecture Behavioral of DisplayInterface is

signal selected : std_logic_vector(31 downto 0);

begin

  selected <= display_reg0 when slide_display(4 downto 0) = "00000" else
              display_reg1 when slide_display(4 downto 0) = "00001" else
			  display_reg2 when slide_display(4 downto 0) = "00010" else
			  display_reg3 when slide_display(4 downto 0) = "00011" else
			  display_reg4 when slide_display(4 downto 0) = "00100" else
			  display_reg5 when slide_display(4 downto 0) = "00101" else
			  display_reg6 when slide_display(4 downto 0) = "00110" else
			  display_reg7 when slide_display(4 downto 0) = "00111" else
			  display_reg8 when slide_display(4 downto 0) = "01000" else
			  display_reg9 when slide_display(4 downto 0) = "01001" else
			  display_reg10 when slide_display(4 downto 0) = "01010" else
			  display_reg11 when slide_display(4 downto 0) = "01011" else
			  display_reg12 when slide_display(4 downto 0) = "01100" else
			  display_reg13 when slide_display(4 downto 0) = "01101" else
			  display_reg14 when slide_display(4 downto 0) = "01110" else
			  display_reg15 when slide_display(4 downto 0) = "01111" else
			  data_out when slide_display(4 downto 0) = "10000" else
			  addr_dm when slide_display(4 downto 0) = "10001" else
			  addr_pm when slide_display(4 downto 0) = "10010" else
			  data_in when slide_display(4 downto 0) = "10011" else
			  instruction when slide_display(4 downto 0) = "11111" else
			  "11111111111111111111111111111111"; 
			  
	led_Out <= selected(31 downto 16) when slide_display(5) = '1' else	    --leftmost switch 
               selected(15 downto 0);	

end Behavioral;






