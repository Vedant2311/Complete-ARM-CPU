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
          
          --multiply
          i_type: in i_decoded_type;
          
          -- Exception
          exception_out : out exception_type;
          IRQ : in std_logic;
          CPSR_I : in std_logic;
          mov_spl : in std_logic;
          
          -- Predication
          
          P_bit: in std_logic;
          
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
  --  signal delay : std_logic:='0'; 
    signal exception_temp : exception_type;
begin
    
   process(clock,Reset)
          begin
          if(Reset = '1') then 
                control_state <= fetch;
                exception_temp <= reset_type;
          
         
          elsif(falling_edge (clock)) then
             
             if exception_temp = reset_type then 
                exception_temp <= no_exception;
              
             elsif IRQ = '0' and exception_temp = irq_type then 
                 exception_temp <= no_exception;
              
              end if;
          
                       
             
            if(Green = '1') then   
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
                     
                     if (i_type = swi) then 
                          control_state <= exception_read;
                          exception_temp <= swi_type;
                          
                         
          
                     elsif (i_type = unknown) then
                          control_state <= exception_read;
                          exception_temp <= undef_type;
           
                                  
                     elsif(P_bit='0' and i_type /= halt) then control_state <= fetch;
                     elsif (i_type = mrs or i_type = msr) then control_state <= res2RF;
                     elsif (instr_class = DP and ((i_type = mul) or (i_type = mla) or (i_type = umull) or (i_type = smull) or (i_type = umlal) or (i_type = smlal))) then control_state <= multiply;
                     elsif(instr_class = DP) then control_state <= shift;
                     elsif(instr_class = DT) then control_state <= addr;
                     elsif(instr_class = branch) then control_state <= brn;
                     --elsif(instr_class = halt) then control_state <= halt;
                     else control_state <=  halt; end if;
                 when shift=>
                    control_state<=arith;
                 
                 -- multiply
                 when multiply =>
                     control_state <= arith;   
                    
                 when arith => 
                    --Red <='0';
                    control_state<= res2RF;
                    
                 when res2RF =>
                    Red<='1';
                    
                    if mov_spl = '1' then
                        exception_temp <= no_exception;
                    end if;
                    
                    if cpsr_I = '0' and IRQ = '1' then
                             control_state<=exception_read;
                             exception_temp <= irq_type;
                           
                     else
                             control_state <= fetch;
                     end if;     
 
                    
                 when addr =>
                   if(LD_bit ='0') then control_state <= mem_wr;
                   else control_state <= mem_rd; end if;
                   --Decision state needed??? NO
                 when mem_wr =>
                    Red<='1';
                    
                    if cpsr_I = '0' and IRQ = '1' then
                             control_state<=exception_read;
                             exception_temp <= irq_type;
                             
                            
                     else
                             control_state <= fetch;
                     end if;     
 
                 when mem_rd =>
                    control_state<= mem2RF;
                    
                 when mem2RF =>
                    Red<='1';
                    
                    if cpsr_I = '0' and IRQ = '1' then
                             control_state<=exception_read;
                             exception_temp <= irq_type;
                             
                            
                     else
                             control_state <= fetch;
                     end if;     
 
                    
                 when brn =>
                    Red<= '1';
                 --   if(delay = '0') then --I want processor to wait in branch state for 2 cycles
                 --       delay<='1';
                 --       control_state<=brn;
                 --   else
                 --       delay<='0';
                       
                 --   end if;
                     if cpsr_I = '0' and IRQ = '1' then
                             control_state<=exception_read;
                             exception_temp <= irq_type;
                             
                            
                     else
                             control_state <= fetch;
                     end if;     
 
                 when halt=>
                    Red<= '1';
                    
                    if cpsr_I = '0' and IRQ = '1' then
                            control_state<=exception_read;
                            exception_temp <= irq_type;
                            
                         
                    else
                            control_state <= fetch;
                    end if;   
                    
                 -- Exception
                 when exception_read => 
                     control_state <= exception_write;
                      
                 when exception_write => 
                     Red <= '0';
                     control_state <= fetch;     
                         
                 when others =>
                  
                    Red<='0';
                    control_state<= fetch;

             end case;
              
            end if; 
              
           end if;
  end process;
  
  exception_out <= exception_temp;
  ctrlstate<=control_state;
end Behavioral;
-- i can treat halt as the other category in