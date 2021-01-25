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
           U_bit: in std_logic;
           C_shift: in std_logic;
           instrIn : in i_decoded_type;		 
		   stateIn : in control_type;
       --    Operation : in STD_LOGIC_VECTOR (2 downto 0);    --can add more operations
           fwe : in STD_LOGIC;
           FLAGS : out STD_LOGIC_VECTOR (3 downto 0):="0000");   --0 1 2 3 = N C Z V
end ALU_Flags;

architecture Behavioral of ALU_Flags is
    signal ans : std_logic_vector(31 downto 0):="00000000000000000000000000000000";     --To keep constant
    signal flag_reg : std_logic_vector(3 downto 0):="0000";     --Flag Register --0 1 2 3 = N C Z V
    signal flag_temp : std_logic_vector(3 downto 0):="0000";
    signal C31,C32 : std_logic;
    signal ansPC:integer;
--	signal ansPC : std_logic_vector(29 downto 0):="000000000000000000000000000000";	-- For PC increment
	signal ansPC_res : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	--signal One : std_logic_vector(29 downto 0) := "000000000000000000000000000001";
begin

-- COMMENT: stateIn added as well

		ansPC <= to_integer(signed(Op1(31 downto 2))) + to_integer(signed(Op2(31 downto 2))) + 1;--Op1+Op2+One;--
	ansPC_res <= std_logic_vector(to_signed(ansPC,30))&"00" when (instrIn = b and stateIn = brn) or (instrIn = beq and stateIn = brn) or (instrIn = bne  and stateIn = brn) else "00000000000000000000000000000000" ;
--    ans<=   Op1+Op2 when (instrIn = add and stateIn = arith) or (instrIn = ldr_plus and stateIn= addr) or (instrIn = str_plus and stateIn= addr) or stateIn = fetch else --Addition
--			Op1-Op2 when (instrIn = sub and stateIn = arith) or (instrIn = cmp and stateIn = arith) or (instrIn = ldr_minus and stateIn= addr) or (instrIn = str_minus and stateIn= addr)  else --Subtraction
--			Op2 when (instrIn = mov and stateIn = arith) else
			
--			ansPC_res when (instrIn = b and stateIn = brn) or (instrIn = beq and stateIn = brn and flag_reg(2)='1') or (instrIn = bne  and stateIn = brn and flag_reg(2)='0') else --PC increment
--			"00000000000000000000000000000000";--check what to put zero or same"0000000000000000000000000000000"; The Answer is Zero since This would lead to a latch and we don't care what an ALU output would be if there is no ALU
  
   ans<=  Op1 and Op2 when instrIn = ande and stateIn = arith else
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
			Op2 when instrIn = mov  and stateIn = arith else
			Op1 and (not(Op2)) when instrIn = bic  and stateIn = arith else
			not(Op2) when instrIn = mvn  and stateIn = arith else
			
			-- DT instructions
		
			Op1 + ((Op2)) when (instrIn = slhb and stateIn= addr and U_bit ='1') or (instrIn = ldr_plus and stateIn= addr) or (instrIn = str_plus and stateIn= addr) or stateIn = fetch else --Addition
			Op1 - Op2 when (instrIn = slhb and stateIn= addr and U_bit ='0') or (instrIn = ldr_minus and stateIn= addr) or (instrIn = str_minus and stateIn= addr)  else --Subtraction
			
			-- Branch instruction
	
			ansPC_res when (instrIn = b and stateIn = brn) or (instrIn = beq and stateIn = brn and flag_reg(2)='1') or (instrIn = bne  and stateIn = brn and flag_reg(2)='0') else 
    	"00000000000000000000000000000000";

    --flag computation
    C31 <= (Op1(31) xor Op2(31)) xor ans(31);
    C32 <= 	(Op1(31) and Op2(31)) or (C31 and Op2(31)) or (Op1(31) and C31);
    
    flag_temp(0) <= ans(31); 
    flag_temp(1) <= C32 when  (instrIn=sub or instrIn=rsb or instrIn=add or instrIn=adc or instrIn=sbc or instrIn=rsc or instrIn=cmp or instrIn=cmn) else
			   C_shift when  (instrIn=ande or instrIn=eor or instrIn=tst or instrIn=teq or instrIn=orr or instrIn=mov or instrIn=bic or instrIn=mvn) else
			   flag_reg(1);
    flag_temp(2) <= '1' when  ans= "00000000000000000000000000000000" else '0' ; 
    flag_temp(3) <= C31 xor C32 when (instrIn=sub or instrIn=rsb or instrIn=add or instrIn=adc or instrIn=sbc or instrIn=rsc or instrIn=cmp or instrIn=cmn) else
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