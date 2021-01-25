----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/24/2019 11:19:12 PM
-- Design Name: 
-- Module Name: Multiplier - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Multiplier is
    Port ( mul1 : in STD_LOGIC_VECTOR (31 downto 0);
           mul2 : in STD_LOGIC_VECTOR (31 downto 0);
            instrin : in i_decoded_type;
           mult_out : out STD_LOGIC_VECTOR (63 downto 0));
          
end Multiplier;

architecture Behavioral of Multiplier is

signal x1 : std_logic := '0';
signal x2 : std_logic := '0';
signal operand1_33 : std_logic_vector(32 downto 0);
signal operand2_33 : std_logic_vector(32 downto 0);

signal result_66 : std_logic_vector(65 downto 0);

begin

x1 <= mul1(31) when instrin = smull or instrin = smlal else '0'; 
x2 <= mul2(31) when instrin = smull or instrin = smlal else '0'; 
operand1_33 <= x1 & mul1; 
operand2_33 <= x2 & mul2;

result_66 <= operand1_33 * operand2_33;
mult_out <= result_66(63 downto 0); 


end Behavioral;
