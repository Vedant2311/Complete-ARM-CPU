----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/10/2018 01:33:44 PM
-- Design Name: 
-- Module Name: Counter 4 bits - Behavioral
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

entity Counter is
    Port ( count : out STD_LOGIC_VECTOR(3 DOWNTO 0);
           clock : in STD_LOGIC );
end Counter;

architecture Behavioral of Counter is
    signal t: STD_LOGIC_VECTOR (3 downto 0);
begin
    process (clock)
    begin
        if(clock='1' and clock'event) then  --Rising Edge triggered
            t <= t+1;
        end if;
    end process;
    count <= t;
end Behavioral;
