----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/24/2019 01:42:28 PM
-- Design Name: 
-- Module Name: Main - Behavioral
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

----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or std_logic_vector values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Main is
    Port ( clock : in STD_LOGIC;
            Reset_CPU : in STD_LOGIC;
           instruction : in std_logic_vector (31 downto 0);
           addr_pm : out std_logic_vector (31 downto 0);
           addr_dm : out std_logic_vector (31 downto 0);
           data_out : out std_logic_vector (31 downto 0);
           data_in : in std_logic_vector (31 downto 0);                  
           we : out STD_LOGIC;
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
          
          -- I have not added the state Output here. Please look into it
          
           );
end Main;

architecture Main_arch of Main is


    type instr_class_type is (DP, DT, branch, unknown);
    type i_decoded_type is (add,sub,cmp,mov,ldr,str,beq,bne,b,halt,unknown);
    signal instr_class : instr_class_type;
    signal i_decoded : i_decoded_type;
    --
    -- Execution control FSM
    type state_type is (initial,onestep,cont,done);
    signal state : state_type := initial;
    
    signal cond : std_logic_vector (3 downto 0);
    signal F_field : std_logic_vector (1 downto 0);
    signal I_bit : std_logic;
    signal shift_spec : std_logic_vector (7 downto 0);
    --
    signal opcode : std_logic_vector(3 downto 0);     --for DP and DT
    signal opc : std_logic_vector(1 downto 0);        --for branch
    signal S_bit : std_logic;                         --for DP
    signal P_bit,U_bit,B_bit,W_bit,L_bit : std_logic; --for DT
    
    --Regsiter addresses and constants
    signal Rn,Rd,Rm : std_logic_vector(3 downto 0);
    signal Imm8 : std_logic_vector(7 downto 0);
    signal Imm12 : std_logic_vector(11 downto 0);
    signal Imm24 : std_logic_vector(23 downto 0);
    
    --Need not take RotSpec and ShiftSpec for this assignment
    --signal RotSpec : std_logic_vector(3 downto 0);
    --signal ShiftSpec : std_logic_vector(7 downto 0);
    
    --Register File and Flag register
    type RF_type is array (0 to 15) of std_logic_vector(31 downto 0);
    signal RF : RF_type:= (others => "00000000000000000000000000000000");
    --Can now be modified for external flag module
    signal Flags : std_logic_vector(3 downto 0); --ZNVO Main Flag register
    
    --internal flags and pc and data from Mem
    signal Z : std_logic;
    signal pc : integer:=0;
    
    --COMMENT added this pc_new for the multiple input 
    
    signal pc_new : integer:= 0;
    
    signal addr :integer; -- To calc and store address values for str and ldr instructions
    signal MemData : std_logic_vector(31 downto 0); -- later to include asynchronous memory read
    --Operands
    signal Op2 : integer;
    signal Op1 : integer;
    signal Offset : integer;
    signal ans : integer;
    
    -- For setting the initial value of PC since in the one step path, the initial will come repeatedly and so it will reset the PC agani!
    
    signal isStarted : std_logic := '0';
    
--Program Begin
begin
    cond <= instruction(31 downto 28);
    F_field <= instruction(27 downto 26);
    I_bit <= instruction(25);
    shift_spec <= instruction (11 downto 4);
    opcode <= instruction(24 downto 21);
    opc <= instruction (25 downto 24);
    
    --single bits decoding
    S_bit <= instruction(20);
    P_bit <= instruction(24);
    U_bit <= instruction(23);
    B_bit <= instruction(22);
    W_bit <= instruction(21);
    L_bit <= instruction(20);
    
    --Register Address
    Rn <= instruction(19 downto 16);
    Rd <= instruction(15 downto 12);
    Rm <= instruction(3 downto 0);
    
    --Constants
    Imm8 <= instruction(7 downto 0);
    Imm12 <= instruction(11 downto 0);
    Imm24 <= instruction(23 downto 0);
    
    
    --First Finding intruc type
    with F_field select 
    instr_class <= DP when "00",
            DT when "01",
            branch when "10",
            unknown when others;
         
     --Decoding instructions
    i_decoded<= add when instr_class = DP     and opcode = "0100" else
                sub when instr_class = DP     and opcode = "0010" else
                mov when instr_class = DP     and opcode = "1101" else
                cmp when instr_class = DP     and opcode = "1010" else
                str when instr_class = DT     and L_bit = '0'     else
                ldr when instr_class = DT     and L_bit = '1'     else
                b   when instr_class = branch and cond = "1110"   else
                beq when instr_class = branch and cond = "0000"   else
                bne when instr_class = branch and cond = "0001"   else
                halt when instruction = "00000000000000000000000000000000" else         -- detecting halt instruction
                unknown;
    
      --ALU begin        
       --Operands  type for DP instructions
       Op2<= to_integer(signed(RF(to_integer(unsigned(Rm))))) when I_bit = '0' and instr_class = DP else
             to_integer(signed(Imm8)) when I_bit = '1' and instr_class = DP else
             0;
       Op1 <= to_integer(signed(RF(to_integer(unsigned(Rn)))));
       
       --Get offset for DT and branch
       Offset <= to_integer(unsigned(Imm12)) when instr_class = DT and U_bit = '1' else
                 to_integer(unsigned(Imm12)) when instr_class = DT and U_bit = '0' else
                 to_integer(signed(Imm24)) when instr_class = branch else
                 0;
                 
        --Executing DP instructions        
        ans <= Op1+Op2 when i_decoded = add else
               Op2 when i_decoded = mov else
               Op1-Op2 when i_decoded = sub or i_decoded = cmp else    --cmp for flag set
               0;
        --Setting flag
        Z <= '1' when i_decoded = cmp and ans = 0 else
             '0';
             
             -- COMMENT PC can be set only when the state is initial
       
         pc_new <= 0 when (slide_program = "000" and state = initial) else
                   128 when slide_program = "001" and state = initial else
                   256 when slide_program = "010" and state = initial else
                   384 when slide_program = "011" and state = initial else
                   512 when slide_program = "100" and state = initial else
                   640 when slide_program = "101" and state = initial else
                   768 when slide_program = "110" and state = initial else
                   896  when slide_program = "111" and state = initial else
                   pc_new;    
             
             
             
        --COMMENT: Changed Branch instructions
        pc <= pc_new when Reset_CPU ='1' or (state = initial and isStarted = '0')  else
              to_integer(unsigned(RF(15))) + 8 + (4*Offset) when i_decoded = b or (i_decoded = beq and Flags(3) = '1') or (i_decoded = bne and Flags(3) = '0') else 
              to_integer(unsigned(RF(15))) + 4;
              
         --Address Calculation for ldr and str
              addr<=to_integer(unsigned((RF(to_integer(unsigned(Rn))))))+Offset; --when i_decoded = str or i_decoded =ldr else
                    
                    --Check if need for a change
 
        ----------ALU END----------     
        
        -------Asynchronous Part--------     
  --Instruction Memory address     
       addr_pm<=RF(15);--std_logic_vector(to_unsigned(pc,32));
  --Reading from Data Memory
 --     RF(to_integer(unsigned(Rd))) <= data_in;
      --addr_dm<=std_logic_vector(to_unsigned(addr,32)) when i_decoded = str or i_decoded =ldr;
      addr_dm<=std_logic_vector(to_unsigned(addr,32)); --when i_decoded = str or i_decoded =ldr;
             
      
      data_out <= RF(to_integer(unsigned(Rd)));
                      
        --enable for writing
       we <=  '1' when i_decoded = str else
              '0' ; 
              
        
          --COMMENT: added this process above the other one
          -- COMMENT: removed the debouncer to test the circuit. Add that again  
          -- COMMENT: Check the debouncer and clk_div codes for more updates
               
        --Process to write data to Register File and Update Flags
  
   process(clock,Reset_CPU)
                begin
                if(falling_edge (clock)) then
                
                   case state is
                   
                     
                       when initial =>
                           --Go overrides Step
                            if(Reset_CPU = '1') then state <= initial; isStarted <= '0';
                            elsif(Go_CPU = '1') then
                               state <= cont;
                            elsif(Step_CPU = '1') then
                               state <= onestep; isStarted <= '1';
                            else state <= initial;
                            end if;
                        
                       when onestep =>
                           state <= done;
                                           
                       when cont => 
                           if(i_decoded = halt) then state <= done; end if;
                       when done => 
                            if(Step_CPU='0' and Go_CPU ='0') then state<= initial; end if;
        
       
          
                       when others => --str and branch intructions and unknown might be problematic for halt as intructin initial vlaue is 0
       
                   end case;
                    
                  end if;
                 end process;
              
  
  
        process(clock,Reset_CPU)
        begin
        if(falling_edge (clock) and((state = onestep) or (state = cont))) then
        
           case i_decoded is
           
             
               when cmp =>
                    Flags(3) <= Z;
    --                we<='0';
                --Can add more flags  as when required
                
               when ldr =>
               RF(to_integer(unsigned(Rd))) <= data_in;
   --                   addr_dm<=std_logic_vector(to_unsigned(addr,32));
          --            we<='0';
                                   
               when add => 
                    RF(to_integer(unsigned(Rd))) <= std_logic_vector(to_signed(ans,32));
  --                  we<='0';
               when sub => 
                    RF(to_integer(unsigned(Rd))) <= std_logic_vector(to_signed(ans,32));
--                  we<='0';

               when mov => 
                    RF(to_integer(unsigned(Rd))) <= std_logic_vector(to_signed(ans,32));
--                  we<='0';
  
               when others => --str and branch intructions and unknown might be problematic for halt as intructin initial vlaue is 0
                    
                    --RF(to_integer(unsigned(Rd))) <= std_logic_vector(to_signed(ans,32));
--                  we<='0';
           end case;
           
           --Update PC i.e. RF15
            RF(15) <= std_logic_vector(to_signed(pc,32));
           -- RF(3) <= std_logic_vector(to_signed(255,32));
            
            --??????check register update
            r0<=RF(0);
            r1<=RF(1);
            r2<=RF(2);
            r3<=RF(3);
            r4<=RF(4);
            r5<=RF(5);
            r6<=RF(6);
            r7<=RF(7);
            r8<=RF(8);
            r9<=RF(9);
            r10<=RF(10);
            r11<=RF(11);
            r12<=RF(12);
            r13<=RF(13);
            r14<=RF(14);
            r15<=RF(15);
          end if;
         end process;
               
         -- Execution Control FSM
                
    
end Main_Arch;
