----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/06/2019 06:01:35 PM
-- Design Name: 
-- Module Name: Scanner - Behavioral
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

entity Scanner is
    Port ( Clock : in STD_LOGIC;
           c_state : in control_type;
           data : out STD_LOGIC_VECTOR (3 downto 0);
           en : out STD_LOGIC;
           
           row_scan : in std_logic_vector(3 downto 0):="1111";
           col_scan : out std_logic_vector(3 downto 0):="1111"
           );
end Scanner;

architecture Behavioral of Scanner is
    signal row : integer range 0 to 3 :=0;
    signal col : integer range 0 to 3 :=0;
begin

    en<='1' when c_state =keypadread and (row_scan = "0111" or row_scan = "1011" or row_scan = "1101" or row_scan = "1110") else '0';
    
    data<= "0001" when col = 0 and row_scan = "0111" else   --1
           "0010" when col = 1 and row_scan = "0111" else   --2
           "0011" when col = 2 and row_scan = "0111" else   --3
           
           "1010" when col = 3 and row_scan = "0111" else   --A
           
           "0100" when col = 0 and row_scan = "1011" else   --4
           "0101" when col = 1 and row_scan = "1011" else   --5
           "0110" when col = 2 and row_scan = "1011" else   --6
           
           "1011" when col = 3 and row_scan = "1011" else   --B
           
           "0111" when col = 0 and row_scan = "1101" else   --7
           "1000" when col = 1 and row_scan = "1101" else   --8
           "1001" when col = 2 and row_scan = "1101" else   --9
           
           "1100" when col = 3 and row_scan = "1101" else   --C
           
           "0000" when col = 0 and row_scan = "1110" else   --0
           "1111" when col = 1 and row_scan = "1110" else   --F
           "1110" when col = 2 and row_scan = "1110" else   --E
           "1101" when col = 3 and row_scan = "1110";-- else   --D
           
           
    process(Clock)
    begin
        if(falling_edge(Clock) and c_state = keypadread) then
            if(col = 3 ) then col<=0; else    col<=col+1; end if;
        end if;
    end process;
    
    col_scan<=  "0111" when col = 0 else
                "1011" when col =1 else
                "1101" when col =2 else
                "1110" when col =3 else
                "1111";
end Behavioral;
