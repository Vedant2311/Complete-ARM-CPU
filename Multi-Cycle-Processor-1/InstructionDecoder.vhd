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
             
             -- predication
             cond: out std_logic_vector(3 downto 0);
             mode : in std_logic_vector(4 downto 0);
             mov_spl : out std_logic;
             control_state : in control_type;
             
             -- Multiply
             wad : out std_logic_vector(3 downto 0);
             wad_optional : out std_logic_vector(3 downto 0);
            
             i_decod : out i_decoded_type);
end InstructionDecoder;

architecture Behavioral of InstructionDecoder is

  signal instr_class : instr_class_type;
  signal i_decoded : i_decoded_type;
 
 signal condTemp : std_logic_vector (3 downto 0);
 signal F_field : std_logic_vector (1 downto 0);
 signal I_bit : std_logic;
 signal shift_spec : std_logic_vector (7 downto 0);
 --
 signal opcode : std_logic_vector(3 downto 0);     --for DP and DT
 signal opc : std_logic_vector(1 downto 0);        --for branch
 signal S_bit : std_logic;                         --for DP
 signal P_bit,U_bit,B_bit,W_bit,L_bit : std_logic; --for DT
 
 --Regsiter addresses and constants
 signal Rn_temp,Rd,Rm : std_logic_vector(3 downto 0);
 signal Imm8 : std_logic_vector(7 downto 0);
 signal Imm12 : std_logic_vector(11 downto 0);
 signal Imm24 : std_logic_vector(23 downto 0);
 
 signal link_bit : std_logic;
 signal mult_decod : std_logic_vector(3 downto 0);
 
 signal valid : std_logic;
 signal mov_spl_temp : std_logic;
begin
    condTemp <= instruction(31 downto 28);
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
   
   -- link bit
   link_bit <= instruction(24);
   
   --Register Address
   Rd <= instruction(15 downto 12);
   Rm <= instruction(3 downto 0);
   
   --Constants
   Imm8 <= instruction(7 downto 0);
   Imm12 <= instruction(11 downto 0);
   Imm24 <= instruction(23 downto 0);
   
   -- Mult
   mult_decod <= instruction(7 downto 4);
   
   
   --First Finding intruc type
--   with F_field select      
--   instr_class <= DP when "00",
--           DT when "01",
--           branch when "10",
--           unknown when others;
  -- COMMENT: Made some changes since the one written by you had the same error which made us work for hours to correct Lab6!
 instr_class <=   halt when instruction = "00000000000000000000000000000000" else
                  DP when F_field = "00"  else
                  DT when F_field = "01" else
                  branch when F_field = "10" else
                  exception when F_field = "11" else
                  unknown;
        
    --Decoding instructions
   i_decoded<= 	
   
       unknown when instruction(27 downto 23) = "00010" and instruction(21 downto 16) = "001111" and instruction(11 downto 0) = "000000000000" and instruction(22)='1' and mode="10000" else
       unknown when instruction(27 downto 23) = "00010" and instruction(21 downto 12) = "1010011111" and instruction(11 downto 4) = "00000000" and instruction(22)='1' and mode="10000" else 
        mrs when instruction(27 downto 23) = "00010" and instruction(21 downto 16) = "001111" and instruction(11 downto 0) = "000000000000" else 
        msr when instruction(27 downto 23) = "00010" and instruction(21 downto 12) = "1010011111" and instruction(11 downto 4) = "00000000" else 
                     
        mul when instr_class = DP and opcode = "0000" and (mult_decod = "1001" and I_bit = '0') else
        mla when instr_class = DP and opcode = "0001" and (mult_decod = "1001" and I_bit = '0') else
        
        umull when instr_class = DP and opcode = "0100" and (mult_decod = "1001" and I_bit = '0') else
        smull when instr_class = DP and opcode = "0110" and (mult_decod = "1001" and I_bit = '0') else
        umlal when instr_class = DP and opcode = "0101" and (mult_decod = "1001" and I_bit = '0') else
        smlal when instr_class = DP and opcode = "0111" and (mult_decod = "1001" and I_bit = '0') else
                                           
        ande when instr_class = DP     and opcode = "0000" and ((I_bit='1') or ((I_bit='0') and ((instruction(4)='0') or ((instruction(4)='1') and (instruction(7)='0'))))) else
		eor when instr_class = DP     and opcode = "0001" and ((I_bit='1') or ((I_bit='0') and ((instruction(4)='0') or ((instruction(4)='1') and (instruction(7)='0'))))) else
		sub when instr_class = DP     and opcode = "0010" and ((I_bit='1') or ((I_bit='0') and ((instruction(4)='0') or ((instruction(4)='1') and (instruction(7)='0'))))) else
		rsb when instr_class = DP     and opcode = "0011" and ((I_bit='1') or ((I_bit='0') and ((instruction(4)='0') or ((instruction(4)='1') and (instruction(7)='0'))))) else
		add when instr_class = DP     and opcode = "0100" and ((I_bit='1') or ((I_bit='0') and ((instruction(4)='0') or ((instruction(4)='1') and (instruction(7)='0'))))) else
		adc when instr_class = DP     and opcode = "0101" and ((I_bit='1') or ((I_bit='0') and ((instruction(4)='0') or ((instruction(4)='1') and (instruction(7)='0'))))) else
		sbc when instr_class = DP     and opcode = "0110" and ((I_bit='1') or ((I_bit='0') and ((instruction(4)='0') or ((instruction(4)='1') and (instruction(7)='0'))))) else
		rsc when instr_class = DP     and opcode = "0111" and ((I_bit='1') or ((I_bit='0') and ((instruction(4)='0') or ((instruction(4)='1') and (instruction(7)='0'))))) else
		tst when instr_class = DP     and opcode = "1000" and S_bit='1' and ((I_bit='1') or ((I_bit='0') and ((instruction(4)='0') or ((instruction(4)='1') and (instruction(7)='0'))))) else
		teq when instr_class = DP     and opcode = "1001" and S_bit='1' and ((I_bit='1') or ((I_bit='0') and ((instruction(4)='0') or ((instruction(4)='1') and (instruction(7)='0'))))) else
		cmp when instr_class = DP     and opcode = "1010" and S_bit='1' and ((I_bit='1') or ((I_bit='0') and ((instruction(4)='0') or ((instruction(4)='1') and (instruction(7)='0'))))) else
		cmn when instr_class = DP     and opcode = "1011" and S_bit= '1' and ((I_bit='1') or ((I_bit='0') and ((instruction(4)='0') or ((instruction(4)='1') and (instruction(7)='0'))))) else
   		orr when instr_class = DP     and opcode = "1100" and ((I_bit='1') or ((I_bit='0') and ((instruction(4)='0') or ((instruction(4)='1') and (instruction(7)='0'))))) else
		mov when instr_class = DP     and opcode = "1101" and ((I_bit='1') or ((I_bit='0') and ((instruction(4)='0') or ((instruction(4)='1') and (instruction(7)='0'))))) else
		bic when instr_class = DP     and opcode = "1110" and ((I_bit='1') or ((I_bit='0') and ((instruction(4)='0') or ((instruction(4)='1') and (instruction(7)='0'))))) else
		mvn when instr_class = DP     and opcode = "1111"  and ((I_bit='1') or ((I_bit='0') and ((instruction(4)='0') or ((instruction(4)='1') and (instruction(7)='0'))))) else
        

               str_plus when instr_class = DT   and U_bit = '1'  and L_bit = '0'  else
               str_minus when instr_class = DT  and U_bit = '0'   and L_bit = '0' else
               ldr_plus when instr_class = DT   and U_bit = '1'  and L_bit = '1'  else
               ldr_minus when instr_class = DT  and U_bit = '0'   and L_bit = '1' else
               
                 bl   when instr_class = branch and condTemp = "1110" and link_bit = '1'  else 
                 bleq when instr_class = branch and condTemp = "0000" and link_bit = '1'  else 
                 blne when instr_class = branch and condTemp = "0001" and link_bit = '1'  else
                             
               b   when instr_class = branch and condTemp = "1110" and instruction(25 downto 24)="10"   else
               beq when instr_class = branch and condTemp = "0000" and instruction(25 downto 24)="10"   else
               bne when instr_class = branch and condTemp = "0001" and instruction(25 downto 24)="10"   else
               
                             
               swi when instr_class = exception else
               
               halt when instruction = "00000000000000000000000000000000" else         -- detecting halt instruction
               unknown;
    --instr_class <= halt when i_decoded = halt; 
    class <= instr_class;-- when IW = '1'; --If doesn't work then pass both i_decoded and class##!!cloud be erroneous!!##changing to instruc for to incoporate halt instruction class
    i_decod <= i_decoded;-- when IW = '1';--write else case
    cond <= condTemp;
    
    -- Multiply
    wad <= instruction(19 downto 16) when i_decoded = mul or i_decoded = mla or i_decoded = smull or i_decoded = smlal or i_decoded = umull or i_decoded = umlal  else
           instruction(15 downto 12);
           
    wad_optional <= instruction(15 downto 12) when i_decoded = smull or i_decoded = smlal or i_decoded = umull or i_decoded = umlal  else
                    "0000";         
    
--    rn <= instruction(15 downto 12) when i_decoded = mul or i_decoded = mla or i_decoded = smull else
--          instruction(19 downto 16);
          
--    rn_optional <= instruction(15 downto 12) when i_decoded = smull or i_decoded = smlal or i_decoded = umull or i_decoded = umlal  else
--                             "0000";                 
    
   mov_spl_temp <= '1' when    instruction = "11100001101100001111000000001110" and mode="10011" else '0';
    
        
       mov_spl <= mov_spl_temp when control_state <= decode;      --Update Flag register
      
end Behavioral;
