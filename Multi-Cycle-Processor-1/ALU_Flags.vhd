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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.state_package.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU_Flags is
    Port ( clock : in STD_LOGIC;
           Op1 : in STD_LOGIC_VECTOR (31 downto 0);
           Op2 : in STD_LOGIC_VECTOR (31 downto 0);
           Result : out STD_LOGIC_VECTOR (31 downto 0);--:="00000000000000000000000000000000";
           S_bit: in std_logic;
           C_shift: in std_logic;
           instrIn : in i_decoded_type;		 
		   stateIn : in control_type;
       --    Operation : in STD_LOGIC_VECTOR (2 downto 0);    --can add more operations
           fwe : in STD_LOGIC;
           
           -- Exception
            mov_spl : in std_logic;
            CPSRin : out std_logic_vector(31 downto 0);
            SPSRin : in std_logic_vector(31 downto 0);
            mode : in std_logic_vector(4 downto 0);
            -- Multiply
            mulOut : in std_logic_vector(63 downto 0);
            mult_rn : in std_logic_vector(31 downto 0);
            mult_rn_low : in std_logic_vector(31 downto 0);
            Result_optional : out std_logic_vector(31 downto 0);
             
            FLAGS : out STD_LOGIC_VECTOR (3 downto 0));   --0 1 2 3 = N C Z V
end ALU_Flags;

architecture Behavioral of ALU_Flags is
    signal ans : std_logic_vector(31 downto 0):="00000000000000000000000000000000";     --To keep constant
    signal flag_reg : std_logic_vector(3 downto 0):="0000";     --Flag Register --0 1 2 3 = N C Z V
    signal flag_temp : std_logic_vector(3 downto 0):="0000";
    signal C31,C32 : std_logic;
    
    signal C63: std_logic;
    signal C64: std_logic;
    
    signal ansPC:integer;
--	signal ansPC : std_logic_vector(29 downto 0):="000000000000000000000000000000";	-- For PC increment
	signal ansPC_res : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	--signal One : std_logic_vector(29 downto 0) := "000000000000000000000000000001";
	signal P_temp : std_logic;
	
	--multiply
	signal mult_temp_out : std_logic_vector(63 downto 0);
	signal Atemp : std_logic_vector(63 downto 0);
begin

-- COMMENT: stateIn added as well

	ansPC <= to_integer(signed(Op1(31 downto 2))) + to_integer(signed(Op2(31 downto 2))) + 1;--Op1+Op2+One;--
	ansPC_res <= std_logic_vector(to_signed(ansPC,30))&"00" when (instrIn = b and stateIn = brn) or (instrIn = beq and stateIn = brn) or (instrIn = bne  and stateIn = brn) or (instrIn = bne  and stateIn = brn) or (instrIn = bl  and stateIn = brn) or (instrIn = blne  and stateIn = brn) else "00000000000000000000000000000000" ;
--    ans<=   Op1+Op2 when (instrIn = add and stateIn = arith) or (instrIn = ldr_plus and stateIn= addr) or (instrIn = str_plus and stateIn= addr) or stateIn = fetch else --Addition
--			Op1-Op2 when (instrIn = sub and stateIn = arith) or (instrIn = cmp and stateIn = arith) or (instrIn = ldr_minus and stateIn= addr) or (instrIn = str_minus and stateIn= addr)  else --Subtraction
--			Op2 when (instrIn = mov and stateIn = arith) else
			
--			ansPC_res when (instrIn = b and stateIn = brn) or (instrIn = beq and stateIn = brn and flag_reg(2)='1') or (instrIn = bne  and stateIn = brn and flag_reg(2)='0') else --PC increment
--			"00000000000000000000000000000000";--check what to put zero or same"0000000000000000000000000000000"; The Answer is Zero since This would lead to a latch and we don't care what an ALU output would be if there is no ALU
  
    mult_temp_out <= mulOut + ((mult_rn)&(mult_rn_low));
    Atemp <= ((mult_rn)&(mult_rn_low));
	
   CPSRin <= SPSRin when mov_spl = '1' and mode = "10011" else
             "00000000000000000000000000000000";
	
   ans<=     
           Op1 and Op2 when instrIn = ande and stateIn = arith else
	       Op1 xor Op2 when instrIn = eor and stateIn = arith else
			Op1 - Op2 when instrIn = sub and stateIn = arith else
			 Op2 - Op1 when instrIn = rsb and stateIn = arith else
			Op1+Op2 when (instrIn = add and stateIn = arith) or (stateIn = fetch) else
			Op1+Op2 + flag_reg(1) when instrIn = adc  and stateIn = arith else
			Op1+ not(Op2) + flag_reg(1) when instrIn = sbc and stateIn = arith  else
			not(Op1)+Op2 + flag_reg(1) when instrIn = rsc and stateIn = arith  else
			Op1 and Op2 when instrIn = tst  and stateIn = arith else
			Op1 xor Op2 when instrIn = teq and stateIn = arith  else
			Op1 - Op2 when instrIn = cmp  and stateIn = arith else
			Op1+Op2 when instrIn = cmn  and stateIn = arith else
			Op1 or Op2 when instrIn = orr  and stateIn = arith else
			Op2 when instrIn = mov and stateIn = arith else
			
			Op1 and (not(Op2)) when instrIn = bic  and stateIn = arith else
			not(Op2) when instrIn = mvn  and stateIn = arith else
			
			-- DT instructions
		
			Op1 + ((Op2)) when (instrIn = ldr_plus and stateIn= addr) or (instrIn = str_plus and stateIn= addr) or stateIn = fetch else --Addition
			Op1 - Op2 when (instrIn = ldr_minus and stateIn= addr) or (instrIn = str_minus and stateIn= addr)  else --Subtraction
			
			-- multiply
			mulOut(31 downto 0) when (instrin = mul and stateIn = arith) else
			mulOut(31 downto 0) + mult_rn when (instrin = mla and stateIn = arith) else
			mult_temp_out(63 downto 32) when ((instrin = smlal) or (instrin = umlal)) else
			mulOut(63 downto 32) when ((instrin = umull) or (instrin = smull)) else
			
			
			-- Branch instruction
	
			ansPC_res when (instrIn = b and stateIn = brn) or (instrIn = beq and stateIn = brn and flag_reg(2)='1') or (instrIn = bne  and stateIn = brn and flag_reg(2)='0') or (instrIn = bl  and stateIn = brn) or (instrIn = bleq  and stateIn = brn and flag_reg(2)='1') or (instrIn = blne  and stateIn = brn and flag_reg(2)='0') else 
    	"00000000000000000000000000000000";
    
    Result_optional <= mulOut(31 downto 0) when ((instrin = umull) or (instrin = smull)) else
                      mult_temp_out(31 downto 0) when ((instrin = smlal) or (instrin = umlal)) else
                      "00000000000000000000000000000000";
    
    --flag computation
    C31 <= (Op1(31) xor Op2(31)) xor ans(31);
    C32 <= 	(Op1(31) and Op2(31)) or (C31 and Op2(31)) or (Op1(31) and C31);
    
    C63 <= ((mulOut(63)) xor (Atemp(63))) xor (mult_temp_out(63)) when ((instrin = umull) or (instrin = smull) or (instrin = smlal) or (instrin = umlal) ) else
            mulOut(63);
            
    C64 <= ((mulOut(63) and Atemp(63)) or (mulOut(63) and C63) or (C63 and Atemp(63))) when ((instrin = umull) or (instrin = smull) or (instrin = smlal) or (instrin = umlal) ) else
            mulOut(63);             
    
    
    flag_temp(0) <= mulOut(63) when instrIn = mul or instrIn = mla else
                    mult_temp_out(63) when instrIn = smull or instrin = umull or instrin = umlal or instrIn = smlal else
                    ans(31) when stateIn = arith else flag_reg(0); 
                    
    flag_temp(1) <= C32 when  (instrIn=sub or instrIn=rsb or instrIn=add or instrIn=adc or instrIn=sbc or instrIn=rsc or instrIn=cmp or instrIn=cmn)   and stateIn = arith else
			   C_shift when  (instrIn=ande or instrIn=eor or instrIn=tst or instrIn=teq or instrIn=orr or instrIn=mov or instrIn=bic or instrIn=mvn)  and stateIn = arith else
			    C64 when (instrIn = smull or instrin = umull or instrin = umlal or instrIn = smlal or instrIn = mul or instrIn = mla) and statein = arith else
			   flag_reg(1) when stateIn = arith else
			   flag_reg(1);
			   
    flag_temp(2) <= '1' when  (ans= "00000000000000000000000000000000" or (mulOut = "0000000000000000000000000000000000000000000000000000000000000000" and (instrIn = mul or instrIn = mla)) or ((mult_temp_out = "0000000000000000000000000000000000000000000000000000000000000000") and (instrIn = smull or instrin = umull or instrin = umlal or instrIn = smlal))) and stateIn = arith else '0' when stateIn = arith else flag_reg(2);
     
    flag_temp(3) <= C31 xor C32 when (instrIn=sub or instrIn=rsb or instrIn=add or instrIn=adc or instrIn=sbc or instrIn=rsc or instrIn=cmp or instrIn=cmn)  and stateIn = arith else
                    C64 xor C63 when (instrIn = smull or instrin = umull or instrin = umlal or instrIn = smlal or instrIn = mul or instrIn = mla) and statein = arith else
                    flag_reg(3) when stateIn = arith else 
                    flag_reg(3);            
          
          
    FLAGS <= flag_reg;  --connect to output
    Result<=ans;        --connect to output
    process(clock)
    begin
    if(falling_edge(clock)) then       
    if fwe ='1' then flag_reg <= flag_temp; end if ;      --Update Flag register
    end if;
     end process;
	--ansPC_res <= "00000000000000000000000000000000";  -- To restore the AnsPC to all Zeros 
end Behavioral;