----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/10/2018 01:33:44 PM
-- Design Name: 
-- Module Name: Comapre - Behavioral
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

entity Comaparator is
    Port ( count : in STD_LOGIC_VECTOR(3 DOWNTO 0);
           value : in STD_LOGIC_VECTOR(3 DOWNTO 0);
           Q : out STD_LOGIC);
end Comaparator;

architecture Behavioral of Comaparator is

begin
    Q<='1' when(count<value)
    else '0';
end Behavioral;
