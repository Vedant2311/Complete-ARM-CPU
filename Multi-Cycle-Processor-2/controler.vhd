----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/10/2018 01:33:44 PM
-- Design Name: 
-- Module Name: Controler - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Controler is
    Port ( clk : in  STD_LOGIC;
           value : in STD_LOGIC_VECTOR(3 DOWNTO 0);
           digit : out std_logic_vector(3 downto 0);
           mode : in STD_LOGIC;
           seg : out STD_LOGIC_VECTOR(6 downto 0));
end Controler;

architecture Behavioral of Controler is
   signal count : STD_LOGIC_VECTOR(3 downto 0);
   signal Q : STD_LOGIC_VECTOR (15 downto 0);
   signal state : STD_LOGIC;
   signal counter : integer:=0;
   begin
   counter1 : entity work.Counter(Behavioral)
        port map(count=>count,clock=>clk);
        
   comaparator1 : entity work.Comaparator(Behavioral)
        port map(count=>count,value=>value,Q=>state);
        
    SSD1 : entity work.SSD(behavioral)
        port map(b=>value,enable=>mode,Q=>seg);

    process(clk)
        begin
        if (mode ='0') then
        
          if (falling_edge(clk)) then
          
             if(Q="000000000000000")then Q<="1111111111111111";
             else Q <= Q(14 downto 0) & '0';    --left shift
             end if;
          
           end if;
         else  Q(0)<=state;
               Q(1)<=state;
               Q(2)<=state;
               Q(3)<=state;
               Q(4)<=state;
               Q(5)<=state;
               Q(6)<=state;
               Q(7)<=state;
               Q(8)<=state;
               Q(9)<=state;
               Q(10)<=state;
               Q(11)<=state;
               Q(12)<=state;
               Q(13)<=state;
               Q(14)<=state;
               Q(15)<=state;
        end if;
        end process;
        
       digit<="1110" ;
end Behavioral;
