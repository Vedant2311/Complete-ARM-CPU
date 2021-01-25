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
use work.state_package.ALL;

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
   --addr_pm : in std_logic_vector (31 downto 0);
   --addr_dm : in std_logic_vector (31 downto 0);
   --data_out : in std_logic_vector (31 downto 0);
   --data_in : in std_logic_vector (31 downto 0);
   
  
   slide_display : in std_logic_vector (5 downto 0);
   
   
 	ctrlstate : in control_type;
	 exstate : in state_type;
	 
  -- Values stored in the temp registers
	
	IR : in std_logic_vector(31 downto 0);
	DR : in std_logic_vector(31 downto 0);
	ALU1 : in std_logic_vector(31 downto 0);
	ALU2 : in std_logic_vector(31 downto 0);
	Res : in std_logic_vector(31 downto 0);
    
    flags : in std_logic_vector(3 downto 0);
-- RF
	
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
                                 
   
   check_CPSR : in std_logic_vector(31 downto 0);
                    check_SPSR : in std_logic_vector(31 downto 0);
                    check_R13_svc : in std_logic_vector(31 downto 0);
                    check_R14_svc : in std_logic_vector(31 downto 0);
                    mode : in std_logic_vector(4 downto 0);
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
			
			
			  "00000000000000000000000000000000"	when slide_display(4 downto 0) = "10000" and ctrlstate = fetch else
			  "00000000000000000000000000000001"	when slide_display(4 downto 0) = "10000" and ctrlstate = decode else
			  "00000000000000000000000000000010"	when slide_display(4 downto 0) = "10000" and ctrlstate = arith else
			  "00000000000000000000000000000011"	when slide_display(4 downto 0) = "10000" and ctrlstate = addr else
			  "00000000000000000000000000000100"	when slide_display(4 downto 0) = "10000" and ctrlstate = brn else
			  "00000000000000000000000000000101"	when slide_display(4 downto 0) = "10000" and ctrlstate = halt else
			  "00000000000000000000000000000110"	when slide_display(4 downto 0) = "10000" and ctrlstate = res2RF else
			  "00000000000000000000000000000111"	when slide_display(4 downto 0) = "10000" and ctrlstate = mem_wr else
			  "00000000000000000000000000001000"	when slide_display(4 downto 0) = "10000" and ctrlstate = mem_rd else
			  "00000000000000000000000000001001"	when slide_display(4 downto 0) = "10000" and ctrlstate = mem2RF else
			  "00000000000000000000000000001010"	when slide_display(4 downto 0) = "10000" and ctrlstate = shift else
              "00000000000000000000000000001011"	when slide_display(4 downto 0) = "10000" and ctrlstate = multiply else   
              "00000000000000000000000000001100" when slide_display(4 downto 0) = "10000" and ctrlstate = exception_read else   
                                                       
			  "11111111111111111111111111111111"	when slide_display(4 downto 0) = "10000"  else
				
			  IR when slide_display(4 downto 0) = "10001" else
			  DR when slide_display(4 downto 0) = "10010" else
			  ALU1 when slide_display(4 downto 0) = "10011" else
			  ALU2 when slide_display(4 downto 0) = "10100" else 
			  Res when slide_display(4 downto 0) = "10101" else
			  
			   "00000000000000000000000000000000"	when slide_display(4 downto 0) = "10110" and exstate = initial else
			   "00000000000000000000000000000001"	when slide_display(4 downto 0) = "10110" and exstate = onestep else
			   "00000000000000000000000000000010"	when slide_display(4 downto 0) = "10110" and exstate = oneinstr else
			   "00000000000000000000000000000011"	when slide_display(4 downto 0) = "10110" and exstate = cont else
			   "00000000000000000000000000000100"	when slide_display(4 downto 0) = "10110" and exstate = done else
			   "11111111111111111111111111111111"	when slide_display(4 downto 0) = "10110"  else
                                
                "0000000000000000000000000000"&(flags(0))&(flags(1))&(flags(2))&(flags(3)) when slide_display(4 downto 0) = "10111" else --NCZV              
                              
                check_cpsr when slide_display(4 downto 0) = "11000" else
                check_spsr when slide_display(4 downto 0) = "11001" else
                check_r13_svc when slide_display(4 downto 0) = "11010" else
                check_r14_svc when slide_display(4 downto 0) = "11011" else              
                "000000000000000000000000000" & mode when slide_display(4 downto 0) = "11100" else               
			  
			  "11111111111111111111111111111111"; 
			  
	led_Out <= selected(31 downto 16) when slide_display(5) = '1' else	    --leftmost switch 
               selected(15 downto 0);	

end Behavioral;





