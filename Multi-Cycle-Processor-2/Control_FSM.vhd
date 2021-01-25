----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/21/2019 02:12:50 PM
-- Design Name: 
-- Module Name: Control_FSM - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Control_FSM is
    Port (Clock: in std_logic;
          Reset: in std_logic;
          Green : in std_logic;
          Red : out std_logic;
          ctrlstate : out control_type;
          instr_class : in instr_class_type;
          i_decod : in i_decoded_type;
          B_bit : in std_logic;
          keyred: in std_logic;
          LD_bit : in std_logic
--          PW : out std_logic;
--          IorD : out std_logic;
--          MR : out std_logic;
--          MW : out std_logic;
--          IW : out std_logic;
--          DW : out std_logic;
--          RW : out std_logic;
--          AW : out std_logic;
--          BW : out std_logic;
--          Rsrc : out std_logic;
--          M2R : out std_logic;
--          Asrc1 : out std_logic;
--          Asrc2 : out std_logic;
--          AW : out std_logic;
          );
          
    
end Control_FSM;

architecture Behavioral of Control_FSM is
    signal control_state : control_type :=fetch; 
    signal delay : std_logic:='0'; 
begin
    ctrlstate<=control_state;
   process(clock,Reset)
          begin
          if(Reset = '1') then control_state <= fetch;
          elsif(falling_edge (clock) and Green = '1') then
          
             case control_state is
             
               
                 when fetch =>                     
                      -- isStarted <= '0';
                      Red<='0';
                      --ctrlstate <= fetch;
                      control_state <= decode;
                  
                 when decode =>
                     --Red <='0';
                     --ctrlstate <= decode;
                     --Extra state needed for decision making input????
                     if(i_decod = slhb and instr_class = DP) then control_state <= addr;
                     elsif(instr_class = DP) then control_state <= shift;
                     elsif(instr_class = DT) then control_state <= addr;
                     elsif(instr_class = branch) then control_state <= brn;
                     elsif(instr_class = I) then control_state <= keypadread;
                     elsif(instr_class = O) then control_state <= screenwrite;
                     --elsif(instr_class = halt) then control_state <= halt;
                     else control_state <=  halt; end if;
                 when shift=>
                    control_state<=arith;
                 when arith => 
                    --Red <='0';
                     control_state<= res2RF;
                 when keypadread =>
                    if(keyred ='1') then
                        control_state <= res2RF;
                    end if;
                 when screenwrite =>
                       Red<='1';
                       control_state<=fetch;
                 when res2RF =>
                    Red<='1';
                    control_state<=fetch;
                 when addr =>
                   if(LD_bit ='0' and (i_decod = slhb or (instr_class = DT and B_bit='1') )) then control_state <=mem_rd;       --The Case of writing hlaf word and bytes
                   elsif(LD_bit ='0' and B_bit ='0' and instr_class = DT) then control_state <= mem_wr;
                   else control_state <= mem_rd; end if;
                   --Decision state needed??? NO
                 when mem_wr =>
                    Red<='1';
                    control_state<= fetch;
                 when mem_rd =>
                    if(LD_bit = '0' and (i_decod = slhb or (instr_class = DT and B_bit='1')) ) then control_state<=mem_wr;     --Case of writing half word and byte
                    else control_state<= mem2RF; end if;
                 when mem2RF =>
                    Red<='1';
                    control_state<= fetch;
                 when brn =>
                    Red<= '1';
                 --   if(delay = '0') then --I want processor to wait in branch state for 2 cycles
                 --       delay<='1';
                 --       control_state<=brn;
                 --   else
                 --       delay<='0';
                        control_state<=fetch;
                 --   end if;
                 when halt=>
                    Red<= '1';
                    control_state<=fetch;
                 when others => 
                    Red<='0';
                    control_state<= fetch;

             end case;
              
           end if;
  end process;
end Behavioral;
-- i can treat halt as the other category in