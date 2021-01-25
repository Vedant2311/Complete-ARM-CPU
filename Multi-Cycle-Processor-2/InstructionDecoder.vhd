----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/21/2019 02:08:20 PM
-- Design Name: 
-- Module Name: InstructionDecoder - Behavioral
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
--   type control_type is (fetch,decode,arith,addr,brn,halt,res2RF,mem_wr,mem_rd,mem2RF);
--end state_package;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.state_package.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity InstructionDecoder is
    Port ( instruction : in STD_LOGIC_VECTOR(31 downto 0);
            --IW : in std_logic;
--           Cond : in STD_LOGIC_VECTOR (3 downto 0);
--           F_field : in STD_LOGIC_VECTOR (1 downto 0);
--           Opcode : in STD_LOGIC_VECTOR (1 downto 0);
--           I_bit : in STD_LOGIC;
--           P_bit : in STD_LOGIC;
--           U_bit : in STD_LOGIC;
--           B_bit : in STD_LOGIC;
--           W_bit : in STD_LOGIC;
--           L_bit : in STD_LOGIC;
--           S_bit : in STD_LOGIC;
--           Opc : in STD_LOGIC_VECTOR (1 downto 0);
--           shift_spec : out STD_LOGIC_VECTOR(7 downto 0);
--           Rn : out STD_LOGIC_VECTOR(3 downto 0);
             class : out instr_class_type;
             i_decod : out i_decoded_type);
end InstructionDecoder;

architecture Behavioral of InstructionDecoder is

  signal instr_class : instr_class_type;
  signal i_decoded : i_decoded_type;
 
 signal cond : std_logic_vector (3 downto 0);
 signal F_field : std_logic_vector (1 downto 0);
 signal I_bit : std_logic;
 signal shift_spec : std_logic_vector (7 downto 0);
 --
 signal opcode : std_logic_vector(3 downto 0);     --for DP and DT
 signal opc : std_logic_vector(1 downto 0);        --for branch
 signal S_bit : std_logic;                         --for DP
 signal P_bit,U_bit,B_bit,W_bit,L_bit : std_logic; --for DT
 signal SH : std_logic_vector(1 downto 0);
 
 --Regsiter addresses and constants
 signal Rn,Rd,Rm : std_logic_vector(3 downto 0);
 signal Imm8 : std_logic_vector(7 downto 0);
 signal Imm12 : std_logic_vector(11 downto 0);
 signal Imm24 : std_logic_vector(23 downto 0);
 
begin
    cond <= instruction(31 downto 28);
    F_field <= instruction(27 downto 26);
    I_bit <= instruction(25);
    shift_spec <= instruction (11 downto 4);
    opcode <= instruction(24 downto 21);
    opc <= instruction (25 downto 24);

--single bits decoding
    S_bit <= instruction(20);
    P_bit <= instruction(24);
    U_bit <= instruction(23);
    B_bit <= instruction(22);
    W_bit <= instruction(21);
    L_bit <= instruction(20);

--Register Address
    Rn <= instruction(19 downto 16);
    Rd <= instruction(15 downto 12);
    Rm <= instruction(3 downto 0);

--Constants
    Imm8 <= instruction(7 downto 0);
    Imm12 <= instruction(11 downto 0);
    Imm24 <= instruction(23 downto 0);
    
--Other fieds and bits
   cond <= instruction(31 downto 28);
   F_field <= instruction(27 downto 26);
   I_bit <= instruction(25);
   shift_spec <= instruction (11 downto 4);
   opcode <= instruction(24 downto 21);
   opc <= instruction (25 downto 24);
   
   --single bits decoding
   S_bit <= instruction(20);
   P_bit <= instruction(24);
   U_bit <= instruction(23);
   B_bit <= instruction(22);
   W_bit <= instruction(21);
   L_bit <= instruction(20);
   SH    <= instruction(6 downto 5);
   
   --Register Address
   Rn <= instruction(19 downto 16);
   Rd <= instruction(15 downto 12);
   Rm <= instruction(3 downto 0);
   
   --Constants
   Imm8 <= instruction(7 downto 0);
   Imm12 <= instruction(11 downto 0);
   Imm24 <= instruction(23 downto 0);
   
   
   --First Finding intruc type
--   with F_field select      
--   instr_class <= DP when "00",
--           DT when "01",
--           branch when "10",
--           unknown when others;
  -- COMMENT: Made some changes since the one written by you had the same error which made us work for hours to correct Lab6!
 instr_class <=   halt when instruction = "00000000000000000000000000000000" else
                  I when  instruction(25 downto 23) = "010" and instruction(21 downto 16) = "001111" and instruction(11 downto 0) = "000000000000" else
                  O when  instruction(25 downto 23) = "010" and instruction(21 downto 4) = "101001111100000000" else
                  DP when F_field = "00" else
                  DT when F_field = "01" else
                  branch when F_field = "10" else
                  unknown;
        
    --Decoding instructions
   i_decoded<= slhb when instr_class =DP     and ((SH="01" or L_bit='1') and I_bit ='0' and instruction(7)='1' and instruction(4)='1' and ((instruction(22)='1')or(instruction(22)='0' and instruction(11 downto 8) ="0000"))) else
        ande when instr_class = DP     and opcode = "0000" else
		eor when instr_class = DP     and opcode = "0001" else
		sub when instr_class = DP     and opcode = "0010" else
		rsb when instr_class = DP     and opcode = "0011" else
		add when instr_class = DP     and opcode = "0100" else
		adc when instr_class = DP     and opcode = "0101" else
		sbc when instr_class = DP     and opcode = "0110" else
		rsc when instr_class = DP     and opcode = "0111" else
		tst when instr_class = DP     and opcode = "1000" else
		teq when instr_class = DP     and opcode = "1001" else
		cmp when instr_class = DP     and opcode = "1010" else
		cmn when instr_class = DP     and opcode = "1011" else
   		orr when instr_class = DP     and opcode = "1100" else
		mov when instr_class = DP     and opcode = "1101" else
		bic when instr_class = DP     and opcode = "1110" else
		mvn when instr_class = DP     and opcode = "1111" else
		mrs when instr_class = I      else
		msr when instr_class = O      else
		slhb when instr_class =DP     and ((SH="01" or L_bit='1') and I_bit ='0' and instruction(7)='1' and instruction(4)='1' and ((instruction(22)='1')or(instruction(22)='0' and instruction(11 downto 8) ="0000"))) else

               str_plus when instr_class = DT   and U_bit = '1'  and L_bit = '0'  else
               str_minus when instr_class = DT  and U_bit = '0'   and L_bit = '0' else
               ldr_plus when instr_class = DT   and U_bit = '1'  and L_bit = '1'  else
               ldr_minus when instr_class = DT  and U_bit = '0'   and L_bit = '1' else
               b   when instr_class = branch and cond = "1110"   else
               beq when instr_class = branch and cond = "0000"   else
               bne when instr_class = branch and cond = "0001"   else
               halt when instruction = "00000000000000000000000000000000" else         -- detecting halt instruction
               unknown;
    --instr_class <= halt when i_decoded = halt; 
    class <= instr_class;-- when IW = '1'; --If doesn't work then pass both i_decoded and class##!!cloud be erroneous!!##changing to instruc for to incoporate halt instruction class
    i_decod <= i_decoded;-- when IW = '1';--write else case
    
end Behavioral;
