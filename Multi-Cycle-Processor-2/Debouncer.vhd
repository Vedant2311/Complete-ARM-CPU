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

entity Debouncer is 
   port(
    
    Reset : in std_logic;
    step : in std_logic;
    go : in std_logic;
    clk_debounce : in std_logic;
    oneinstr : in std_logic;
    
    oneinstr_CPU : out std_logic;
    Reset_CPU : out std_logic;
    step_CPU : out std_logic;
    go_CPU : out std_logic
   );
 
  end Debouncer;
  
  architecture Behavioral of Debouncer is
  
  signal temp_Reset_CPU: std_logic := '0';
  signal temp_step_CPU: std_logic := '0';
  signal temp_go_CPU: std_logic := '0';
  signal temp_oneinstr_CPU : std_logic := '0';
  
 begin
 
  process(clk_debounce)
    begin 
 
		if(falling_edge(clk_debounce)) then 
		   
		     temp_Reset_CPU <= Reset;
			 temp_step_CPU <= step;
			 temp_go_CPU <= go;
		     temp_oneinstr_CPU <= oneinstr;
		   
		   end if;
		   
		          
		    
    end process;
	
	step_CPU <= temp_step_CPU;
    go_CPU<=temp_go_CPU;
    Reset_CPU <= temp_Reset_CPU;
    oneinstr_CPU <= temp_oneinstr_CPU;
            
	
  end Behavioral;
