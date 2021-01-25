----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/10/2018 05:41:49 PM
-- Design Name: 
-- Module Name: SSD - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SSD is
    Port ( b : in STD_LOGIC_VECTOR (3 downto 0);
           enable : in STD_LOGIC;
           Q : out STD_LOGIC_VECTOR (6 downto 0));
end SSD;

architecture Behavioral of SSD is
    signal t : STD_LOGIC_VECTOR(15 downto 0);
   begin
   
    with  b select t<=
    "0000000000000001" when "0000", 
    "0000000000000010" when "0001" ,
    "0000000000000100" when "0010" ,
    "0000000000001000" when "0011" ,
    "0000000000010000" when "0100"  ,   
    "0000000000100000" when "0101"   ,  
    "0000000001000000" when "0110" ,
    "0000000010000000" when "0111"  ,   
    "0000000100000000" when "1000" ,
    "0000001000000000" when "1001" ,
    "0000010000000000" when "1010" ,
    "0000100000000000" when "1011" ,
    "0001000000000000" when "1100" ,
    "0010000000000000" when "1101" ,
    "0100000000000000" when "1110" ,
    "1000000000000000" when "1111" ,
    "0000000000000000" when others;
    
    process(b)
    begin
    if(enable ='0') then
        Q<="1111111";   --all segements off
     else
        Q(0)<=t(1)or t(4) or t(11) or t(13);
        Q(1)<=t(5) or t(6) or t(11) or t(12) or t(14) or t(15);
        Q(2)<=t(2) or t(12) or t(14) or t(15);
        Q(3)<=t(1) or t(4) or t(7)  or t(10) or t(15);
        Q(4)<=t(1) or t(3) or t(4) or t(5) or t(7) or t(9);
        Q(5)<=t(13) or t(7) or t(3) or t(2) or t(1);
        Q(6)<=t(0) or t(1) or t(7) or t(12);
    end if;
    end process;

end Behavioral;
