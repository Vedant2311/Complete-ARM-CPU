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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Top_Module is
    Port ( Clock : in STD_LOGIC;
           Reset : in STD_LOGIC;
          
           step: in std_logic;
           go : in std_logic;
           
           -- Things to  be observed as per me: 
              -- 1. data_in
              -- 2. data_out
              -- 3. addr_pm
              -- 4. addr_dm
              -- 5. instruction
              -- 6. States
              -- 7. The 16 RF values
          -- slide_display(5) to show either the first half or the last half of the bits           
           
           slide_display : in std_logic_vector(5 downto 0);
           
           -- Given in the slides
           slide_program : in std_logic_vector(2 downto 0);
           
           -- LED outs
           ledOut : out std_logic_vector (15 downto 0)
           );
end Top_Module;

architecture Behavioral of Top_Module is
-------Component Instantiation---------

--CPU
COMPONENT Main is
    Port ( clock : in STD_LOGIC;
           Reset_CPU : in STD_LOGIC;
           instruction : in std_logic_vector (31 downto 0);
           addr_pm : out std_logic_vector (31 downto 0);
           addr_dm : out std_logic_vector (31 downto 0);
           data_out : out std_logic_vector (31 downto 0);
           data_in : in std_logic_vector (31 downto 0);                  
           we : out STD_LOGIC;
      --????????Check registers     
            r0 : out std_logic_vector(31 downto 0);
           r1 : out std_logic_vector(31 downto 0);
           r2 : out std_logic_vector(31 downto 0);
           r3 : out std_logic_vector(31 downto 0);
           r4 : out std_logic_vector(31 downto 0);
           r5 : out std_logic_vector(31 downto 0);
           r6 : out std_logic_vector(31 downto 0);
           r7 : out std_logic_vector(31 downto 0);
            r8 : out std_logic_vector(31 downto 0);
             r9 : out std_logic_vector(31 downto 0);
              r10 : out std_logic_vector(31 downto 0);
               r11 : out std_logic_vector(31 downto 0);
                r12 : out std_logic_vector(31 downto 0);
                 r13 : out std_logic_vector(31 downto 0);
                  r14 : out std_logic_vector(31 downto 0);
                   r15 : out std_logic_vector(31 downto 0);
                    
           step_CPU : in std_logic;
           go_CPU : in std_logic;
           
           slide_program : in std_logic_vector (2 downto 0)
           
           -- Add State output
           
          );          
 end COMPONENT;

--Data Memory
COMPONENT RAM IS
  PORT (
    a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    d : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    clk : IN STD_LOGIC;
    we : IN STD_LOGIC;
    spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

--Program Memory
COMPONENT ROM IS
  PORT (
    a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;



 -- Clock Divider
 component clk_div is
   port(
   
   Clock: in std_logic;
   
   clk_debounce : out std_logic
   );
 end component;
 
 
 -- Debouncer
  component Debouncer is 
   port(
    
    Reset : in std_logic;
    step : in std_logic;
    go : in std_logic;
    clk_debounce : in std_logic;
    
    Reset_CPU : out std_logic;
    step_CPU : out std_logic;
    go_CPU : out std_logic
   );
 
  end component;
  
  -- Display interface
  component DisplayInterface is 
  port(
  
   instruction : in std_logic_vector (31 downto 0);
   addr_pm : in std_logic_vector (31 downto 0);
   addr_dm : in std_logic_vector (31 downto 0);
   data_out : in std_logic_vector (31 downto 0);
   data_in : in std_logic_vector (31 downto 0);
   slide_display : in std_logic_vector (5 downto 0);
   
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
                                 
   
   
   -- Add the States input from the CPU
   
   led_Out : out std_logic_vector (15 downto 0) 
  
  );
  
  end component;
  
  
   --Signals to connect
   
   --Address from CPU
    signal addr_pm :std_logic_vector (31 downto 0);
    signal addr_dm :std_logic_vector (31 downto 0);
    --Adress to Memories
    signal addr_rom :std_logic_vector (7 downto 0);
    signal addr_ram :std_logic_vector (7 downto 0);
    --
    signal instr: std_logic_vector (31 downto 0); --instruction from ROM
    signal write_en: std_logic; --we for RAM
    --Data flow between RAM and CPU
    signal data_to_RAM :std_logic_vector(31 downto 0);
    signal data_to_CPU :std_logic_vector(31 downto 0);
    --To check
    signal check0 : std_logic_vector(31 downto 0);
    signal check1 : std_logic_vector(31 downto 0);
    signal check2 : std_logic_vector(31 downto 0);
    signal check3 : std_logic_vector(31 downto 0);
    signal check4 : std_logic_vector(31 downto 0);
    signal check5 : std_logic_vector(31 downto 0);
    signal check6 : std_logic_vector(31 downto 0);
    signal check7 : std_logic_vector(31 downto 0);
    signal check8 : std_logic_vector(31 downto 0);
    signal check9 : std_logic_vector(31 downto 0);
    signal check10 : std_logic_vector(31 downto 0);
    signal check11 : std_logic_vector(31 downto 0);
    signal check12 : std_logic_vector(31 downto 0);
    signal check13 : std_logic_vector(31 downto 0);
    signal check14 : std_logic_vector(31 downto 0);
    signal check15 : std_logic_vector(31 downto 0);
    
--    signal vect_check0 : std_logic_vector(31 downto 0);
--    signal vect_check1 : std_logic_vector(31 downto 0);
--    signal vect_check2 : std_logic_vector(31 downto 0);
--    signal vect_check3 : std_logic_vector(31 downto 0);
--    signal vect_check4 : std_logic_vector(31 downto 0);
--    signal vect_check5 : std_logic_vector(31 downto 0);
--    signal vect_check6 : std_logic_vector(31 downto 0);
--    signal vect_check7 : std_logic_vector(31 downto 0);
--    signal vect_check8 : std_logic_vector(31 downto 0);
--    signal vect_check9 : std_logic_vector(31 downto 0);
--    signal vect_check10 : std_logic_vector(31 downto 0);
--    signal vect_check11 : std_logic_vector(31 downto 0);
--    signal vect_check12 : std_logic_vector(31 downto 0);
--    signal vect_check13 : std_logic_vector(31 downto 0);
--    signal vect_check14 : std_logic_vector(31 downto 0);
--    signal vect_check15 : std_logic_vector(31 downto 0);
                                    
    
    
    signal step_CPU : std_logic;
    signal go_CPU : std_logic; 
    signal reset_CPU : std_logic;
    
    signal clk_debounce : std_logic;
    
    signal led_Out : std_logic_vector (15 downto 0);
    
begin
    --Port Mapping between different components
    
--RAM
DM : RAM
port map(a=>addr_ram,
         d=>data_to_RAM,
         clk=>Clock,
         we=>write_en,
         spo=>data_to_CPU
        );
        
--ROM
PM : ROM
port map(a=>addr_rom,
         spo=>instr
        );
        
-- Divider

Div : clk_div
port map(

   Clock => Clock,
   clk_debounce => clk_debounce
);        
        
--Debouncer
Deb : Debouncer
port map(

  Reset => Reset,
  step => step,
  go => go,
  clk_debounce => clk_debounce,
  
  Reset_CPU => Reset_CPU,
  go_CPU => go_CPU,
  step_CPU => step_CPU


);

-- CPU
CPU: Main
port map(
         clock => Clock,
         Reset_CPU=>Reset_CPU,
         step_CPU => step_CPU,
         go_CPU => go_CPU,
         slide_program => slide_program,
         
         -- Add the state output
         
         instruction=>instr,
         addr_dm=>addr_dm,
         addr_pm=>addr_pm,
         data_out=>data_to_RAM,
         data_in=>data_to_CPU,
         we=>write_en,
          r0=>check0,             
                
         r1=>check1,
         r2=>check2,
         r3=>check3,
         r4=>check4,
         r5=>check5,
         r6=>check6,
         r7=>check7,
         r8=>check8,
         r9=>check9,
         r10=>check10,
         r11=>check11,
         r12=>check12,
         r13=>check13,
         r14=>check14,
         r15=>check15
                 
        );
        
--       vect_check0 <=  std_logic_vector(to_signed(check0,32));
--       vect_check1 <=  std_logic_vector(to_signed(check1,32));
--       vect_check2 <=  std_logic_vector(to_signed(check2,32));
--       vect_check3 <=  std_logic_vector(to_signed(check3,32));
--       vect_check4 <=  std_logic_vector(to_signed(check4,32));
--       vect_check5 <=  std_logic_vector(to_signed(check5,32));
--       vect_check6 <=  std_logic_vector(to_signed(check6,32));
--       vect_check7 <=  std_logic_vector(to_signed(check7,32));
       
--       vect_check8 <=  std_logic_vector(to_signed(check8,32));
--       vect_check9 <=  std_logic_vector(to_signed(check9,32));
--       vect_check10 <=  std_logic_vector(to_signed(check10,32));
--       vect_check11 <=  std_logic_vector(to_signed(check11,32));
--       vect_check12 <=  std_logic_vector(to_signed(check12,32));
--       vect_check13 <=  std_logic_vector(to_signed(check13,32));
--       vect_check14 <=  std_logic_vector(to_signed(check14,32));
--       vect_check15 <=  std_logic_vector(to_signed(check15,32));
       
       
       
               
Display : DisplayInterface
port map(

   instruction => instr,
   addr_dm => addr_dm,
   addr_pm => addr_pm,
   data_out => data_to_RAM,
   data_in => data_to_CPU,
   slide_display => slide_display,
   -- Add for the state
   display_reg0 => check0,
   display_reg1 => check1,
   display_reg2 => check2,
   display_reg3 => check3,
   display_reg4 => check4,
   display_reg5 => check5,
   display_reg6 => check6,
   display_reg7 => check7,
   display_reg8 => check8,
   display_reg9 => check9,
   display_reg10 => check10,
   display_reg11 => check11,
   display_reg12 => check12,
   display_reg13 => check13,
   display_reg14 => check14,
   display_reg15 => check15,
                           
   
   
   led_Out => led_Out

);        
        
        ledOut <= led_Out;
        ----END Port Mapping------
        --Address parsing
        addr_rom<=addr_pm(9 downto 2);
        addr_ram<=addr_dm(9 downto 2);

end Behavioral;