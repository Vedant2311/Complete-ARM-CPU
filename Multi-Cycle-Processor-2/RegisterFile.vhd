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
                                                                                        check15 : out std_logic_vector(31 downto 0)
                                                                                                                         
);
end RegisterFile;

architecture Behavioral of RegisterFile is
    --Register File and Flag register
type RF_type is array (0 to 15) of std_logic_vector(31 downto 0);
signal RF : RF_type:= (others => "00000000000000000000000000000000");
--Can now be modified for external flag module
--signal Flags : std_logic_vector(3 downto 0); --ZNVO Main Flag register

--internal flags and pc and data from Mem
--signal Z : std_logic;
signal pc : integer:=0;

begin
    --Reading from RF
    rd1<=RF(to_integer(unsigned(rad1)));
    rd2<=RF(to_integer(unsigned(rad2)));
    pc_read<=RF(15);
    --Process to write RF
    process(clock)
    begin
        if(falling_edge(clock)) then
            if(we = '1') then RF(to_integer(unsigned(wad))) <= wd; end if;
            if(pcwe = '1') then RF(15)<= pc_write; end if;
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

end Behavioral;