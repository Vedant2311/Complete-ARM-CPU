----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/21/2019 01:58:41 PM
-- Design Name: 
-- Module Name: RegisterFile - Behavioral
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
use work.state_package.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RegisterFile is
    Port ( clock : in STD_LOGIC;
           wd : in STD_LOGIC_VECTOR (31 downto 0);
           wad : in STD_LOGIC_VECTOR (3 downto 0);
           we : in STD_LOGIC;
           rad1 : in STD_LOGIC_VECTOR (3 downto 0);
           rad2 : in STD_LOGIC_VECTOR (3 downto 0);
           rd1 : out STD_LOGIC_VECTOR (31 downto 0);
           rd2 : out STD_LOGIC_VECTOR (31 downto 0);
           pcwe : in STD_LOGIC;
           pc_read : out STD_LOGIC_VECTOR(31 downto 0);
           pc_write : in STD_LOGIC_VECTOR(31 downto 0);
           
           blwe : in std_logic;
                        --Outputting the values
           -- multiply
            rmul1 : in std_logic_vector(3 downto 0);
            rmul2 : in std_logic_vector(3 downto 0);
             wad_optional : in std_logic_vector(3 downto 0);         
            i_type : in i_decoded_type;
            rd3 : out std_logic_vector(31 downto 0);
            wad3 : in std_logic_vector(3 downto 0);
           rd4 : out std_logic_vector(31 downto 0);
            we_optional : in std_logic;
            wd_optional : in std_logic_vector(31 downto 0);     
                      
           --Exception
            FlagsIn : in std_logic_vector(3 downto 0);           
            mode : in std_logic_vector(4 downto 0);
            cpsr_we : in std_logic;
            SPSR_we : in std_logic;  
            exception_in : in exception_type;         
            control_state : in control_type; 
            cpsr_i : out std_logic;      
             Ps : in std_logic;   
             IRQ : in std_logic;  
             reset : in std_logic;         
             fwe : in std_logic;
             
            tempCPSR : in std_logic_vector(31 downto 0);
            mov_spl : in std_logic;          
                      
        check0 : out std_logic_vector(31 downto 0);
        check1 : out std_logic_vector(31 downto 0);
        check2 : out std_logic_vector(31 downto 0);
        check3 : out std_logic_vector(31 downto 0);
        check4 : out std_logic_vector(31 downto 0);
        check5 : out std_logic_vector(31 downto 0);
        check6 : out std_logic_vector(31 downto 0);
        check7 : out std_logic_vector(31 downto 0);
        check8 : out std_logic_vector(31 downto 0);
        check9 : out std_logic_vector(31 downto 0);
        check10 : out std_logic_vector(31 downto 0);
        check11 : out std_logic_vector(31 downto 0);
        check12 : out std_logic_vector(31 downto 0);
        check13 : out std_logic_vector(31 downto 0);
        check14 : out std_logic_vector(31 downto 0);
        check15 : out std_logic_vector(31 downto 0);
        
        --Exception display
        check_CPSR : out std_logic_vector(31 downto 0);
        check_SPSR : out std_logic_vector(31 downto 0);
        check_R13_svc : out std_logic_vector(31 downto 0);
        check_R14_svc : out std_logic_vector(31 downto 0)
        
);
end RegisterFile;

architecture Behavioral of RegisterFile is
    --Register File and Flag register
type RF_type is array (0 to 15) of std_logic_vector(31 downto 0);
signal RF : RF_type:= (others => "00000000000000000000000000000000");
--Can now be modified for external flag module
--signal Flags : std_logic_vector(3 downto 0); --ZNVO Main Flag register

-- Exception
signal CPSR : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
signal SPSR : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
signal R13_svc : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
signal R14_svc : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";


signal CPSR_temp : std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
signal SPSR_temp : std_logic_vector(31 downto 0):= "00000000000000000000000000000000";


signal I_temp : std_logic;
--internal flags and pc and data from Mem
--signal Z : std_logic;
signal pc : integer:=0;



signal msr_temp : std_logic_vector(31 downto 0);
signal flags_temp : std_logic_vector(3 downto 0);

begin
    --Reading from RF
    rd1<=    r13_svc when (rad1="1101" and mode="10011") or (((i_type = mul) or (i_type = mla) or (i_type = umull) or (i_type = smull) or (i_type = umlal) or (i_type = smlal)) and (rmul1="1101" and mode="10011")) else
             r14_svc when (rad1="1110" and mode="10011") or (((i_type = mul) or (i_type = mla) or (i_type = umull) or (i_type = smull) or (i_type = umlal) or (i_type = smlal)) and (rmul1="1110" and mode="10011")) else
             RF(to_integer(unsigned(rmul1))) when ((i_type = mul) or (i_type = mla) or (i_type = umull) or (i_type = smull) or (i_type = umlal) or (i_type = smlal)) else  
             RF(to_integer(unsigned(rad1)));
             
    rd2<=    r13_svc when (rad2="1101" and mode="10011") or (((i_type = mul) or (i_type = mla) or (i_type = umull) or (i_type = smull) or (i_type = umlal) or (i_type = smlal)) and (rmul2="1101" and mode="10011")) else
              r14_svc when (rad2="1110" and mode="10011") or (((i_type = mul) or (i_type = mla) or (i_type = umull) or (i_type = smull) or (i_type = umlal) or (i_type = smlal)) and (rmul2="1110" and mode="10011")) else
              RF(to_integer(unsigned(rmul2))) when ((i_type = mul) or (i_type = mla) or (i_type = umull) or (i_type = smull) or (i_type = umlal) or (i_type = smlal)) else  
              RF(to_integer(unsigned(rad2)));
     
    
    rd3 <=  r13_svc when (wad3 = "1101" and mode="10011") else
            r14_svc when (wad3 = "1110" and mode="10011") else  
            RF(to_integer(unsigned(wad3)));
            
    rd4 <=  r13_svc when (wad = "1101" and mode="10011") else
            r14_svc when (wad = "1110" and mode="10011") else             
            RF(to_integer(unsigned(wad)));    

    pc_read<=RF(15);
    
    flags_temp <= CPSR(31 downto 28); 
   -- Exception
    I_temp <= '1' when control_state = exception_read or reset='1' else CPSR(7);
    CPSR_temp <= FlagsIn&("00000000000000000000")&(I_temp)&("00")&mode;
    
    
    msr_temp <= RF(to_integer(unsigned(rmul1)));
    
    --Process to write RF
    process(clock)
    begin
        if(falling_edge(clock) ) then
         
              
            if (blwe = '1') then 
            
               if mode="10011" then
                 r14_svc <= RF(15); 
               else
                RF(14) <= RF(15); 
               end if;
               
            end if;
            
            if(pcwe = '1') then RF(15)<= pc_write; end if;
            
            
            
            if(exception_in = reset_type and control_state = fetch) then 
                RF(15) <= "00000000000000000000000000000000";
             elsif(exception_in = undef_type and control_state = exception_read) then
               RF(15) <= "00000000000000000000000000000100";
             elsif(exception_in = swi_type and control_state = exception_read) then
               RF(15) <= "00000000000000000000000000001000";
             elsif((IRQ='1') and CPSR(7)='0' and control_state = exception_read) then 
               RF(15) <= "00000000000000000000000000011000";
             end if;
        
          
             if(spsr_we = '1') then 
                        
                SPSR <= CPSR; 
                
                r14_svc <= RF(15);        
                
                              
              end if;
                        
                       
          
            if (cpsr_we = '1') then 
            
           
                CPSR <= Flags_temp&("00000000000000000000")&(I_temp)&("00")&"10011";
             
             
             end if;

           if(fwe = '1') and (spsr_we = '0') and (cpsr_we = '0') then 
               CPSR <= CPSR_temp;
           end if;

            if (we_optional = '1') then 
                
                if (wad_optional = "1101" and mode="10011") then 
                              
                    r13_svc <= wd_optional; 
                elsif (wad_optional = "1110" and mode="10011") then
                    r14_svc <= wd_optional;
                else
                    RF(to_integer(unsigned(wad_optional))) <= wd_optional; 
                end if;
            end if;
            
               if(we = '1') then
                     
                      if(i_type /= mrs and i_type/=msr) then
                         if (wad = "1101" and mode="10011") then 
                           
                             r13_svc <= wd; 
                         elsif (wad = "1110" and mode="10011") then
                             r14_svc <= wd;
                         else
                             RF(to_integer(unsigned(wad))) <= wd; 
                         end if;
                         
                         if(mov_spl = '1' and mode="10011") then 
                             CPSR <= SPSR;
                         end if;
                      else
                      
                        if(i_type = mrs) then 
                            
                            if Ps= '1' then 
                               if mode="10011" then
                                  RF(to_integer(unsigned(wad3))) <= SPSR;
                               else
                                  RF(to_integer(unsigned(wad3))) <= "00000000000000000000000000000000"; --Zero since no SPSR for user
                               end if;
                                  
                            else
                               RF(to_integer(unsigned(wad3))) <= CPSR;
                            end if;
                            
                         else
                            if mode="10011" then
                               if Ps= '1' then 
             
                                  SPSR <=RF(to_integer(unsigned(rmul1)));
                               else
                                  CPSR <= RF(to_integer(unsigned(rmul1)));
                                end if;
                             else
                                 if Ps= '1' then 
                                  
                                 
                                  SPSR <= msr_temp(31 downto 28)&(SPSR_temp(27 downto 0));
                               else
                                  
                                  CPSR <= msr_temp(31 downto 28)&(CPSR_temp(27 downto 0));
                                end if;
             
                                 
                             end if;               
                                            
                         end if;
                      
                      end if;
                     
                     end if;
                     
                     
            
        end if;
    end process;
    
    check0 <= RF(0);
        check1 <= RF(1);
        check2 <= RF(2);
        check3 <= RF(3);
        check4 <= RF(4);
        check5 <= RF(5);
        check6 <= RF(6);
        check7 <= RF(7);
        check8 <= RF(8);
        check9 <= RF(9);
        check10 <= RF(10);
        check11 <= RF(11);
        check12 <= RF(12);
        check13 <= RF(13);
        check14 <= RF(14);
        check15 <= RF(15);
        
         --Exception display
       check_CPSR <= CPSR;
       check_SPSR <= SPSR;
       check_R13_svc <= r13_svc;
       check_R14_svc <= r14_svc;

       cpsr_i <= CPSR(7);
end Behavioral;