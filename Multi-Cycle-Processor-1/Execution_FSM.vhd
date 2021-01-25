----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/21/2019 02:11:50 PM
-- Design Name: 
-- Module Name: Execution_FSM - Behavioral
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

entity Execution_FSM is
    Port ( clock : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Step : in STD_LOGIC;
           Instr : in STD_LOGIC;
           Go : in STD_LOGIC;
           Red: in STD_LOGIC;
           Green : out STD_LOGIC;
           control_state : in control_type;
           exstate : out state_type);
end Execution_FSM;

architecture Behavioral of Execution_FSM is
    -- Execution control FSM
    --type state_type is (initial,onestep,oneinstr,cont,done);
    signal state : state_type := initial;
    --signal isStarted : std_logic := '0';

begin
    exstate<=state; --give state as output
   process(clock,Reset)
             begin
             if(Reset ='1') then state <= initial;
             elsif(falling_edge (clock)) then
             
                case state is
                
                  
                    when initial =>
                        Green <= '0';
                        --Go overrides Instr which overrides Step
                         --if(Reset = '1') then state <= initial; --isStarted <= '0';
                         if(Go = '1') then
--                            Green <=  '1';
                            state <= cont;
                         elsif(Instr = '1') then
  --                          Green <= '1';
                            state <= oneinstr;
                         elsif(Step = '1') then
    --                        Green <= '1';
                            state <= onestep;-- isStarted <= '1';
                         else state <= initial;
                         end if;
                     
                    when onestep =>
                        Green <= '1';
                        state <= done;
                    when oneinstr =>
                        Green <= '1'; 
                        if(Red = '1') then state <= done; end if;    
                    when cont => 
                        Green <= '1';
                        if(control_state = halt) then state <= done; end if;
                    when done => 
                        Green <= '0';
                        if(Step='0' and Go ='0' and Instr = '0') then state<= initial; end if;
     
    
       
                    when others =>
    
                end case;
                 
              end if;
     end process;

end Behavioral;