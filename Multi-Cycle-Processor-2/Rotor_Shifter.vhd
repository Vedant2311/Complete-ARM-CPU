
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/21/2019 02:03:11 PM
-- Design Name: 
-- Module Name: ALU_Flags - Behavioral
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
--package state_package is
--   type instr_class_type is (DP, DT, branch,halt, unknown);
--   type i_decoded_type is (ande,eor,sub,rsb, add,adc, sbc, rsc, tst, teq, cmp, cmn, orr,mov,bic, mvn,ldr_plus,ldr_minus,str_plus,str_minus,beq,bne,b,halt,red,unknown);
--   --
--   -- Execution control FSM
--   type state_type is (initial,onestep,oneinstr,cont,done);
--   -- Contorl FSM
--   type control_type is (fetch,decode,shift,arith,addr,brn,halt,res2RF,mem_wr,mem_rd,mem2RF);
--end state_package;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Rotor_Shifter is
    Port ( shift_type : in STD_LOGIC_VECTOR (1 downto 0); -- instruction(11 downto 8) 
           Op2 : in STD_LOGIC_VECTOR (31 downto 0);
           shamt : in std_logic_vector (31 downto 0);
	   I_bit : in std_logic;
	   Result : out STD_LOGIC_VECTOR (31 downto 0):="00000000000000000000000000000000";
	   C_in: in std_logic;
	   C_out: out std_logic
           );
end Rotor_Shifter;

architecture Behavioral of Rotor_Shifter is
	
signal Answer : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

signal Answer1 : std_logic_vector(31 downto 0);
signal Answer2 : std_logic_vector(31 downto 0);
signal Answer3 : std_logic_vector(31 downto 0);
signal Answer4 : std_logic_vector(31 downto 0);
signal Answer5 : std_logic_vector(31 downto 0);



signal amount : integer range 0 to 31;	
signal temp : std_logic_vector(4 downto 0);
signal err : integer  range 0 to 31;
		

signal v1 : std_logic;
signal v2 : std_logic_vector(1 downto 0);
signal v3 : std_logic_vector(3 downto 0);
signal v4 : std_logic_vector(7 downto 0);
signal v5 : std_logic_vector(15 downto 0);

signal signBit1 : std_logic;
signal signBit2 : std_logic_vector(1 downto 0);
signal signBit3 : std_logic_vector(3 downto 0);
signal signBit4 : std_logic_vector(7 downto 0);
signal signBit5 : std_logic_vector(15 downto 0);

		
begin

	  
		amount <= to_integer(unsigned(shamt(4 downto 0)));        --assuming shamt in under required values
	        
	     signBit1 <= Op2(31);
	   
	    temp <= shamt(4 downto 0);
	   
	    Answer1 <= Op2;
	   
	    v1 <= Answer1(0);
	   
	   
	   
	    Answer2 <= Answer1(30 downto 0)&'0' when temp(0) = '1' and shift_type = "00" else
	              '0'&(Answer1(31 downto 1)) when temp(0) = '1' and shift_type = "01" else
	               (signBit1)&(Answer1(31 downto 1)) when temp(0) = '1' and shift_type = "10" else
	               (v1)&(Answer1(31 downto 1)) when temp(0) = '1' and shift_type = "11" else
	               Answer1;
	               
	    v2 <= Answer2(1 downto 0);
	    signBit2 <= signBit1&signBit1;            
                                    
	    Answer3 <= Answer2(29 downto 0)&"00" when temp(1) = '1' and shift_type = "00" else
                          "00"&(Answer2(31 downto 2)) when temp(1) = '1' and shift_type = "01" else
                           (signBit2)&(Answer2(31 downto 2)) when temp(1) = '1' and shift_type = "10" else
                           (v2)&(Answer2(31 downto 2)) when temp(1) = '1' and shift_type = "11" else
                           Answer2;
                           
        v3 <= Answer3(3 downto 0);
        signBit3 <= signBit2&signBit2;
        
        Answer4 <= Answer3(27 downto 0)&"0000" when temp(2) = '1' and shift_type = "00" else
                                  "0000"&(Answer3(31 downto 4)) when temp(2) = '1' and shift_type = "01" else
                                   (signBit3)&(Answer3(31 downto 4)) when temp(2) = '1' and shift_type = "10" else
                                   (v3)&(Answer3(31 downto 4)) when temp(2) = '1' and shift_type = "11" else
                                   Answer3;
                            
        v4 <= Answer4(7 downto 0);
        signBit4 <= signBit3&signBit3;
                                         
        Answer5 <= Answer4(23 downto 0)&"00000000" when temp(3) = '1' and shift_type = "00" else
                   "00000000"&(Answer4(31 downto 8)) when temp(3) = '1' and shift_type = "01" else
                  (signBit4)&(Answer4(31 downto 8)) when temp(3) = '1' and shift_type = "10" else
                  (v4)&(Answer4(31 downto 8)) when temp(3) = '1' and shift_type = "11" else
                   Answer4;
                   
                   
        v5 <= Answer5(15 downto 0);
        signBit5 <= signBit4&signBit4;
                                                            
        Answer <= Answer5(15 downto 0)&"0000000000000000" when temp(4) = '1' and shift_type = "00" else
                  "0000000000000000"&(Answer5(31 downto 16)) when temp(4) = '1' and shift_type = "01" else
                   (signBit5)&(Answer5(31 downto 16)) when temp(4) = '1' and shift_type = "10" else
                   (v5)&(Answer5(31 downto 16)) when temp(4) = '1' and shift_type = "11" else
                   Answer5;
                           
	    
	   
        err<= 0 when amount=0 else     --this should never get assigned
                amount-1;
                
		C_out <= C_in when (I_bit='1') or (I_bit='0' and amount=0) else
		        Op2(32 - amount) when (I_bit='0' and shift_type = "00") else
				Op2(err);
				
		Result <= Answer;
		
end Behavioral;