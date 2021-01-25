----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/28/2019 03:28:28 PM
-- Design Name: 
-- Module Name: Multi_Cycle_Processor - Behavioral
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
package state_package is
   type instr_class_type is (DP,I,O, DT, branch,halt, unknown);
   type i_decoded_type is (ande,eor,sub,rsb, add,adc, sbc, rsc, tst, teq, cmp, cmn, orr,mov,bic, mvn,ldr_plus,ldr_minus,str_plus,str_minus,slhb,beq,bne,b,halt,mrs,msr,red,unknown);
   --
   -- Execution control FSM
   type state_type is (initial,onestep,oneinstr,cont,done);
   -- Contorl FSM
   type control_type is (fetch,decode,shift,arith,addr,brn,halt,res2RF,mem_wr,mem_rd,mem2RF,keypadread,screenwrite);
end state_package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.state_package.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Multi_Cycle_Processor is
    Port ( Resetin : in STD_LOGIC;
           Clockin : in STD_LOGIC;
           Onestepin : in STD_LOGIC;
           Oneinstrin : in STD_LOGIC;
           rowin : in std_logic_vector(3 downto 0);
           colout : out std_logic_vector(3 downto 0);
           cathode : out std_logic_vector(6 downto 0);
           anode : out std_logic_vector(3 downto 0);
           slide_display: in std_logic_vector(5 downto 0);
           
            ledOut : out std_logic_vector (15 downto 0);

           Goin : in STD_LOGIC);
end Multi_Cycle_Processor;

architecture Behavioral of Multi_Cycle_Processor is
----Component Instantiation-------
--Clock divider
component clk_div is
   port(
   Clock: in std_logic;
   clk_debounce : out std_logic
   );
 end component;
 
 --Debouncer
 component Debouncer is 
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
  end component;

--Screen referesher
COMPONENT controler is
    Port ( clk : in  STD_LOGIC;
       value : in STD_LOGIC_VECTOR(3 DOWNTO 0);
       mode : in STD_LOGIC;
       digit : out std_logic_vector(3 downto 0);
       seg : out STD_LOGIC_VECTOR(6 downto 0)
    );
    end component;
--Keypad scanner
COMPONENT scanner is
    port(
    Clock: in std_logic;
    c_state : in control_type;
    data : out std_logic_vector;
    en : out std_logic;
    row_scan : in std_logic_vector(3 downto 0);
    col_scan : out std_logic_vector(3 downto 0)
    );
    end component;
--Rotor_Shifter--
COMPONENT Rotor_Shifter is
      Port ( shift_type : in std_logic_vector(1 downto 0);
             I_bit : in std_logic;
             shamt : in std_logic_vector(31 downto 0);
             Op2 : in STD_LOGIC_VECTOR (31 downto 0);
             C_in :in std_logic;
             C_out:out std_logic;
		     Result : out std_logic_vector(31 downto 0));
 end COMPONENT;


component DisplayInterface is
    Port ( 
	
   instruction : in std_logic_vector (31 downto 0);
   --addr_pm : in std_logic_vector (31 downto 0);
   --addr_dm : in std_logic_vector (31 downto 0);
   --data_out : in std_logic_vector (31 downto 0);
   --data_in : in std_logic_vector (31 downto 0);
   
  
   slide_display : in std_logic_vector (5 downto 0);
   
   
 	ctrlstate : in control_type;
	 exstate : in state_type;
	 
  -- Values stored in the temp registers
	
	IR : in std_logic_vector(31 downto 0);
	DR : in std_logic_vector(31 downto 0);
	ALU1 : in std_logic_vector(31 downto 0);
	ALU2 : in std_logic_vector(31 downto 0);
	Res : in std_logic_vector(31 downto 0);
     flags : in std_logic_vector(3 downto 0);
-- RF
	
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



--ALU_Flags--
COMPONENT ALU_Flags is
    Port ( clock : in STD_LOGIC;
       Op1 : in STD_LOGIC_VECTOR (31 downto 0);
       Op2 : in STD_LOGIC_VECTOR (31 downto 0);
       Result : out STD_LOGIC_VECTOR (31 downto 0):="00000000000000000000000000000000";
       instrIn : in i_decoded_type;         
       stateIn : in control_type;
       S_bit : in std_logic;
       U_bit : in std_logic;
       C_shift : in std_logic;
       --Operation : in STD_LOGIC_VECTOR (2 downto 0);    --can add more operations
       fwe : in STD_LOGIC;
       FLAGS : out STD_LOGIC_VECTOR (3 downto 0):="0000");   --Can add more 
 end COMPONENT;

----Register File----
COMPONENT RegisterFile is
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
end COMPONENT;

----Instruction Decoder----
COMPONENT InstructionDecoder is
    Port ( instruction : in STD_LOGIC_VECTOR(31 downto 0);
           class : out instr_class_type;
           --IW : in std_logic;
           i_decod : out i_decoded_type);
end COMPONENT;

----Control FSM----
COMPONENT Control_FSM is
        Port (Clock: in std_logic;
      Reset: in std_logic;
      Green : in std_logic;
      Red : out std_logic;
      ctrlstate : out control_type;
      instr_class : in instr_class_type;
      LD_bit : in std_logic;
      B_bit : in std_logic;
      keyred : in std_logic;
      i_decod : in i_decoded_type
--          PW : out std_logic;
--          IorD : out std_logic;
--          MR : out std_logic;
--          MW : out std_logic;
--          IW : out std_logic;
--          DW : out std_logic;
--          RW : out std_logic;
--          AW : out std_logic;
--          BW : out std_logic;
--          Rsrc : out std_logic;
--          M2R : out std_logic;
--          Asrc1 : out std_logic;
--          Asrc2 : out std_logic;
--          AW : out std_logic;
      );
end COMPONENT;

----Execution FSM----
COMPONENT Execution_FSM is
    Port ( clock : in STD_LOGIC;
       Reset : in STD_LOGIC;
       Step : in STD_LOGIC;
       Instr : in STD_LOGIC;
       Go : in STD_LOGIC;
       Red: in STD_LOGIC;
       Green : out STD_LOGIC;
       control_state : in control_type;
       exstate : out state_type);
end COMPONENT;
    
COMPONENT dist_mem_gen_0 is
  PORT (
  a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  d : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  clk : IN STD_LOGIC;
  we : IN STD_LOGIC;
  spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
);
end COMPONENT;
----Constants----
    signal four: std_logic_vector(31 downto 0):="00000000000000000000000000000100";
    constant EX : std_logic_vector(19 downto 0):="00000000000000000000";
    signal S1 : std_logic_vector(23 downto 0);
    signal S2 : std_logic_vector(5 downto 0);
    signal Signb : std_logic_vector(23 downto 0);
    signal Signh : std_logic_vector(15 downto 0);

    signal Hword : std_logic_vector(15 downto 0);
    signal byte : std_logic_vector(7 downto 0);
    signal SHword : std_logic_vector(15 downto 0);
    signal Sbyte : std_logic_vector(7 downto 0);
    constant Z27 : std_logic_vector(26 downto 0):="000000000000000000000000000";
    constant zero : std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
----Intermmediate Registers------
    signal IR : std_logic_vector(31 downto 0):="00000000000000000000000000000000";
    signal DR : std_logic_vector(31 downto 0):="00000000000000000000000000000000";
    signal A : std_logic_vector(31 downto 0):="00000000000000000000000000000000";
    signal BB : std_logic_vector(31 downto 0):="00000000000000000000000000000000";
    signal RES : std_logic_vector(31 downto 0):="00000000000000000000000000000000";
    signal SR:std_logic_vector(31 downto 0):="00000000000000000000000000000000";
    signal DIR : std_logic_vector(3 downto 0):="0000";

-------Mux ouputs-----
    signal Asrc1_out: std_logic_vector(31 downto 0);
    signal Asrc2_out: std_logic_vector(31 downto 0);
    signal Rsrc_out: std_logic_vector(3 downto 0);
    signal Rsrc1_out: std_logic_vector(3 downto 0);
    signal M2R_out: std_logic_vector(31 downto 0);
    signal IorD_out: std_logic_vector(7 downto 0);
    
------Control signals----
    --To enable read and write to components and register
    signal PW: std_logic:='0';
    signal MR: std_logic:='0';
    signal MW: std_logic:='0';
    signal IW: std_logic := '0';
    signal DW: std_logic := '0';
    signal AW: std_logic:='0';
    signal BW: std_logic:='0';
    signal RW: std_logic:='0';
    signal SW: std_logic:='0';
    signal ReW: std_logic:='0';
    signal Fset: std_logic:='0';
    signal DiW : std_logic:='0';
   -- signal op: std_logic_vector(2 downto 0);    --to be extended
    --Output From different components
    signal flag_out: std_logic_vector(3 downto 0); --0,1,2,3 = N,C,Z,V
    signal pc_out: std_logic_vector(31 downto 0);
    signal alu_out: std_logic_vector(31 downto 0);  --for PC Update
    signal mem_out: std_logic_vector(31 downto 0);  --Apply conditions to store in IR or DR
    signal mem_in: std_logic_vector(31 downto 0); -- to store half words
    signal DW_in: std_logic_vector(31 downto 0);  --Apply conditions to store in IR or DR
    signal roshi_out: std_logic_vector(31 downto 0);
    signal roshi_in: std_logic_vector(31 downto 0);
    signal shift_type:std_logic_vector(1 downto 0);
    signal rd1: std_logic_vector(31 downto 0);
    signal rd2: std_logic_vector(31 downto 0);
    signal instr_class : instr_class_type;                --
    signal i_decod : i_decoded_type;
    --To control mux
    signal IorD: std_logic;
    signal Rsrc: std_logic;
    signal Rsrc1:std_logic;
    signal M2R: std_logic;
    signal Asrc1: std_logic;
    signal Asrc2: std_logic_vector(1 downto 0);
    --FSM control signals
    signal Green: std_logic;
    signal Red: std_logic;
    signal control_state: control_type;
    signal exec_state: state_type;
    signal I_bit: std_logic;
    signal L_bit: std_logic;
    signal S_bit: std_logic;
    signal B_bit: std_logic;
    signal U_bit : std_logic;
    signal shift_I: std_logic;  --for specifying shift from reg or imm
    signal SH : std_logic_vector(1 downto 0);
    signal branch: std_logic;   --to check if branch or not
    signal Imm: std_logic_vector(31 downto 0);      --To compute Imm for DP and DT
    signal operand2 : std_logic_vector(31 downto 0);
    signal shamt : std_logic_vector(31 downto 0);
    signal DP_shamt : std_logic_vector(31 downto 0);
    signal DT_shamt : std_logic_vector(31 downto 0);
    signal C_shift: std_logic;
    --signal const: std_logic_vector(31 downto 0);
    --signal ex_offset: std_logic_vector(31 downto 0);
    --signal zex_offset: std_logic_vector(31 downto 0);
    --temporary
    signal Reg2: std_logic_vector(31 downto 0);
    
    signal res_in: std_logic_vector(31 downto 0);
    --Keypad and display
    signal keyin : std_logic_vector(3 downto 0);    --hex input 
    signal keyen : std_logic;
    
    signal mode : std_logic:='1';
      --Board testing
        
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
            signal oneinstr_CPU : std_logic;
            
            signal clk_debounce : std_logic;
            
            signal led_Out : std_logic_vector (15 downto 0);
        
        -- Debugginh
            signal temp : integer := 0;

    
begin
------Port mapping-----

Div : clk_div
        port map(
        
           Clock => Clockin,
           clk_debounce => clk_debounce
        );        
                            
Deb: Debouncer
port map(

  Reset => Resetin,
  step => Onestepin,
  go => Goin,
  clk_debounce => clk_debounce,
  oneinstr => Oneinstrin,
  
  oneinstr_CPU => oneinstr_CPU,
  Reset_CPU => Reset_CPU,
  go_CPU => go_CPU,
  step_CPU => step_CPU


);
DD: controler
port map(
        clk=>clk_debounce, --Change if needed
        value=>DIR,
        digit=>anode,
        mode=>mode,
        seg=>cathode
        );
KS: Scanner
port map(
        Clock=>Clk_debounce,
        c_state=>control_state,
        data =>keyin,
        en => keyen,
        col_scan => colout,
        row_scan => rowin
        );
--Rot_shift
RoSh: Rotor_Shifter
port map(
        shift_type=>shift_type,
        Op2=>Asrc2_out ,
        shamt=>shamt,
        I_bit=>I_bit,
        Result=>roshi_out,
        C_in=>flag_out(1),
        C_out=>C_shift
        );
--ALU Flags
AF: ALU_Flags
port map(
        clock=>clockin,
        Op1=>Asrc1_out,
        Op2=>Operand2,
        Result=>alu_out,
        S_bit=>S_bit,
        U_bit=>U_bit,
        C_shift=>C_shift,
        Instrin=>i_decod,
        statein=>control_state,
       -- Operation=>op,
        fwe=>Fset,
        FLAGS=>flag_out
        );
--Register File
RF: RegisterFile
port map(
        clock=>clockin,
        wd=>M2R_out,
        wad=>IR(15 downto 12),
        we =>RW,
        rad1=>Rsrc1_out,
        rad2=>Rsrc_out,
        rd1=>rd1,
        rd2=>rd2,
        pcwe=>PW,
        pc_read=>pc_out,
        pc_write=>alu_out,
        
          check0 => check0,
                          check1 => check1,
                          check2 => check2,
                          check3 => check3,
                          check4 => check4,
                          check5 => check5,
                          check6 => check6,
                          check7 => check7,
                          check8 => check8,
                          check9 => check9,
                          check10 => check10,
                          check11 => check11,
                          check12 => check12,
                          check13 => check13,
                          check14 => check14,
                          check15 => check15
                             --As ALU is doing PC calcualtions
        );
        
MM: dist_mem_gen_0
        port map(
                a=>IorD_out,
                d=>mem_in,
                spo=>mem_out,
                clk=>clockin,
                we=>MW
                );
        
        
ID: InstructionDecoder
port map(
        instruction=>IR,        
        class=>instr_class,
        i_decod=>i_decod
        --IW => IW
        );
--Control FSM
C_FSM: Control_FSM
port map(
        Clock=>clockin,
        Reset=>reset_CPU,
        Green=>Green,
        Red=>Red,
        ctrlstate=>control_state,
        instr_class=>instr_class,
        LD_bit=>L_bit,
        B_bit=>B_bit,
        keyred=>keyen,
        i_decod=>i_decod
        --I think we need to give values for orange signas from the control FSM but now I think we need to calculate it 
--          PW : out std_logic;
--          IorD : out std_logic;
--          MR : out std_logic;
--          MW : out std_logic;
--          IW : out std_logic;
--          DW : out std_logic;
--          RW : out std_logic;
--          AW : out std_logic;
--          BW : out std_logic;
--          Rsrc : out std_logic;
--          M2R : out std_logic;
--          Asrc1 : out std_logic;
--          Asrc2 : out std_logic;
--          AW : out std_logic
        );
--Execution_FSM


-- Display interface
                DI : DisplayInterface
                port map(
                
                  instruction => IR,
                   --addr_pm : in std_logic_vector (31 downto 0);
                   --addr_dm : in std_logic_vector (31 downto 0);
                   --data_out : in std_logic_vector (31 downto 0);
                   --data_in : in std_logic_vector (31 downto 0);
                   
                
                    slide_display => slide_display,
                   
                   
                     ctrlstate => control_state,
                     exstate => exec_state,
                  -- Values stored in the temp registers
                    
                    IR => IR,
                    DR => DR,
                    ALU1 => Asrc1_out,
                    ALU2 => Operand2,
                    Res => alu_out,
                    flags => flag_out,
                -- RF
                    
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
                                                                                
                   
                   
                   -- Add the States input from the CPU
                   
                   led_Out => led_out
                    
                
                
                );        



EF: Execution_FSM
port map(
        clock=>clockin,
        Reset=>reset_cpu,
        Step=>step_cpu,
        Instr=>oneinstr_cpu,
        Go=>Go_cpu,
        Red=>Red,
        Green=>Green,
        control_state=>control_state,
        exstate=>exec_state
        );
--Memory
        --port map 
        --Decode Operands
        --rotor shifter made lab 8 dp instr added

----Register Update
--        IR<=mem_out when IW='1' else IR;
--        DR<=mem_out when DW='1' else DR;
--        A<=rd1 when AW ='1' else A;
--        BB<=rd2 when BW ='1' else BB;
--        RES<=ALU_out when ReW ='1' else RES;
--Keyboard input
        res_in<="0000000000000000000000000000"&keyin when control_state = keypadread else ALU_out;
--Loading Half Words and bytes and selecting-Extension logic
    --##Check if to be checked on Asrc2_out or or RESULT i.e. Res registersomething else
        Hword<=mem_out(31 downto 16) when RES(1) = '1' else mem_out(15 downto 0);     --Half word select
        byte<=mem_out(31 downto 24) when RES(1 downto 0) = "11" else                  --Byte select
              mem_out(23 downto 16) when RES(1 downto 0) = "10" else
              mem_out(15 downto 8) when RES(1 downto 0) = "01" else
              mem_out(7 downto 0);
        Signh<="0000000000000000" when byte(7) ='0' else "1111111111111111";
        Signb<= "111111111111111111111111" when  Hword(15)='1' else "000000000000000000000000";    --sing bit c
        
        DW_in<= Signb&byte when i_decod =slhb and I_bit ='0' and L_bit ='1' and SH ="10" else     --Loading Signed Byte
                Signh&Hword when i_decod =slhb and I_bit ='0' and L_bit ='1' and SH ="11"  else           --Loading signed Half word
                "0000000000000000"&Hword when i_decod =slhb and I_bit ='0' and L_bit ='1' and SH ="01"  else           --Loading unsigned Half word
                "000000000000000000000000"&byte when instr_class = DT and L_bit ='1' and B_bit ='1' else                               --Loading unsigned byte    
                mem_out;
--Storing Half words and Bytes  and extension logic 
        --First read from the memory then write after changing a half word/ byte only  


        mem_in <= DR(31 downto 8)&BB(7 downto 0) when (L_bit ='0'and RES(1 downto 0) = "00") and ((i_decod = slhb and SH ="10" and I_bit ='0') or (instr_class = DT and B_bit ='1'))  else                      --Writing Byte at least pos
                  DR(31 downto 16)&BB(7 downto 0)&DR(7 downto 0) when (L_bit ='0'and RES(1 downto 0) = "01") and ((i_decod = slhb and SH ="10" and I_bit ='0') or (instr_class = DT and B_bit ='1'))  else      -- Writing Byte at right mid
                  DR(31 downto 24)&BB(7 downto 0)&DR(15 downto 0) when (L_bit ='0'and RES(1 downto 0) = "10") and ((i_decod = slhb and SH ="10" and I_bit ='0') or (instr_class = DT and B_bit ='1'))  else     --Writing Byte at left mid
                  BB(7 downto 0)&DR(23 downto 0) when (L_bit ='0'and RES(1 downto 0) = "11") and ((i_decod = slhb and SH ="10" and I_bit ='0') or (instr_class = DT and B_bit ='1'))  else                      --Writing Byte at Highest pos
                 --Half word writes
                  DR(31 downto 16)&BB(15 downto 0) when L_bit ='0' and i_decod =slhb and SH(0)='1' and I_bit ='0' and RES(1)='0' else
                  BB(31 downto 16)&DR(15 downto 0) when L_bit ='0' and i_decod =slhb and SH(0)='1' and I_bit ='0' and RES(1)='1' else
                  BB;       --else write back the read value  
            
--Rotate and shift nad sign extension
    -- sign extension of Imm24
        S2<="000000" when IR(23) ='0' else "111111";
        S1<= "111111111111111111111111" when  (IR(11)='1' and i_decod = slhb) else "000000000000000000000000";    --sing bit c
        Imm<=EX&IR(11 downto 0) when instr_class = DT else --Zero extension of Imm12 for DT
             S1&IR(7 downto 0) when instr_class = DP and i_decod /= slhb else -- sign extension 
             S1&IR(11 downto 8)&IR(3 downto 0) when instr_class = DP and i_decod = slhb else
             zero; --Imm address for SH instrcutions 
        --offset<=IR(23 downto 0);
        --ex_offset<=S2&offset; 
        --zex_offset<=ex_offset(29 downto 0)&"00";
    --Rotation
        --1.shift amount for DP instructions inlcude
        DP_shamt<=SR when shift_I = '1' and I_bit<='0' and IR(7) ='0' else --register specified for regsiter
               Z27&IR(11 downto 7) when shift_I='0' and I_bit<='0'  else     --Constant specified for register
               Z27&IR(11 downto 8)&"0" when I_bit ='1' else
               zero;         --2*Rotation for constant by appending Zero
        --2.shift amount for DT instructions        
        DT_shamt<= Z27&IR(11 downto 7) when shift_I='0' and I_bit<='1'  else     --Constant specified for register no extra cycle needed
                    zero;
        shamt<=DP_shamt when instr_class= DP and i_decod /=slhb else
               DT_shamt when instr_class =DT else
               zero;       
        shift_type<=IR(6 downto 5) when (I_bit = '0' and instr_class = DP) or (I_bit = '1' and instr_class = DT) else "11";
        Operand2<=roshi_out when (instr_class = DP and i_decod /= slhb and control_state = arith) or (instr_class =DT and  control_state = addr) else Asrc2_out;       --Rotate all DP instructions ## Do we need to write this after Asrc2_out?? include DT later 
                                                --Exclude rotate for slhb if exits 
--Multiplexer logic
        
        IorD_out<=pc_out(9 downto 2) when IorD ='0' else RES(9 downto 2);
        Rsrc_out<=IR(3 downto 0) when Rsrc='0' else IR(15 downto 12);
        Rsrc1_out<=IR(19 downto 16) when Rsrc1='0' else IR(11 downto 8);    --give shift amt register address
        M2R_out<=RES when M2R ='0' else DR;
        Asrc1_out<=pc_out when Asrc1 ='0' else A;
        Asrc2_out<=BB when Asrc2="00" else  --rotation  and shift
                    four when Asrc2="01" else
                    Imm when Asrc2="10"else  --Need to take care of rotation and constants for DP instructions
                    S2&IR(23 downto 0)&"00";--zex_offset;--(std_logic_vector(to_signed( (to_integer(signed(IR(23 downto 0)))*4),26 )))
                    

----Mux select inputs--(Should this be inside process???)
        --ldr/str and Immm/reg distinction check on basis of flag if branch or not
        L_bit<=IR(20);
        I_bit<=IR(25);
        S_bit<=IR(20);
        shift_I<=IR(4);
        SH<=IR(6 downto 5);
        B_bit<=IR(22);
        U_bit<=IR(23);
        --Imm<=(not I_bit) when instr_class = DT else I_bit; --I for DP,, not I for DT
        branch<='1' when (control_state = brn) and ((i_decod = b) or (i_decod = beq and flag_out(2)='1') or (i_decod = bne and flag_out(2)='0')) else '0';
        --####WHat to do when not branching???
        IorD<='1' when control_state=mem_rd or control_state=mem_wr  else '0';  --was res to RF 
        M2R<='0' when control_state=res2RF else '1';    -- write back to RF from alu then 0 else from memory
        Rsrc<='1' when ((control_state=decode) and (I_bit='0') and((i_decod=str_plus) or (i_decod=str_minus))) else '0'; --Check when to give 1 and 0 ### also op??##what to input
        Rsrc1<='1' when control_state=shift else '0';    --TO give register specifying shift
        Asrc1<='0' when control_state=fetch or branch='1' else '1';
        Asrc2<=--"00" when (control_state=arith and I_bit<='0') or(control_state = addr and I_bit<='1' and i_decod /=slhb) or(control_state = addr and i_decod =slhb and IR(22)='0')  else
               "01" when control_state=fetch  else   --PC increment
               "11" when branch ='1' else     --Branch instr
               "10" when (control_state=addr and I_bit='0' and i_decod /=slhb) or (control_state=arith and I_bit='1') or (control_state = addr and i_decod =slhb and IR(22)='1')  else
             -- else "00"; 
               "00";
        --Daring try
        PW<='1' when Green='1' and (control_state=fetch or branch ='1') else '0';
        MW<='1' when control_state =mem_wr else '0';
        RW<='1' when (control_state = res2RF and not (i_decod = tst or i_decod = teq or i_decod = cmp or i_decod = cmn)) or control_state = mem2RF else '0';
        MR<='1' when control_state =fetch or control_state =mem_rd else '0';
        
        IW<='1' when control_state = fetch else '0';
        DW<='1' when control_state = mem_rd else '0';
        AW<='1' when control_state = decode else '0';
        BW<='1' when control_state = decode else '0';
        ReW<='1' when control_state = arith or control_state = addr or control_state = keypadread else '0';    --for keypad read
        SW<='1' when control_state = shift else '0';   --to get register specified shift amount
        Fset<='1' when S_bit ='1' and control_state = arith else '0'; -- AFlags set by DP instructions when S bit is 1
        DiW <= '1' when control_state = screenwrite else '0';
--Logic for Operands and offset calculation

    
         ledout <= led_out;



      --ALU begin   
--      op<="000" when i_decod=add else
--           "001" when i_decod = sub else
--           "010" when i_decod = mov else
--           "011" when i_decod = cmp else
--           "100";   --cmp      
-- --Operands  type for DP instructions
-- Op2<= to_integer(signed(RF(to_integer(unsigned(Rm))))) when I_bit = '0' and instr_class = DP else
--       to_integer(signed(Imm8)) when I_bit = '1' and instr_class = DP else
--       0;
-- Op1 <= to_integer(signed(RF(to_integer(unsigned(Rn)))));
 
-- --Get offset for DT and branc9h
-- Offset <= to_integer(unsigned(Imm12)) when instr_class = DT and U_bit = '1' else
--           to_integer(unsigned(Imm12)) when instr_class = DT and U_bit = '0' else
--           to_integer(signed(Imm24)) when instr_class = branch else
--           0;
-------Orange signals control logic--------
    process(clockin,resetin)
    begin
        if(falling_edge(clockin)) then
            if IW='1' then IR<=mem_out; 
            elsif DW='1' then DR<=DW_in; end if;
            if AW='1' then A<=rd1; end if;
            if BW='1' then BB<=rd2; end if;
            if ReW='1' then RES<=res_in; end if;
            if SW='1' then SR<=rd1; end if;
            if DiW ='1' then DIR <=BB(3 downto 0); end if;
        end if;
--    if(falling_edge(clockin)) then
--        if(resetin='1') then
--       --Default Zeros
--        ---PW<='0';
--        ---MR<='0';
--        ---MW<='0';
--        ---IW<='0';
--        ---DW<='0';
--        ---AW<='0';
--        ---BW<='0';
--        ---RW<='0';
--        ---ReW<='0';
--        end if;
        
--         case control_state is
--            when fetch=>
--                --Instruction memory read
--                ---MR<='1';
--                --IW<='1';
--                ---PW<='1';
                
--                --Default Zeros
----	         	---PW<='0';
----	     	    MR<='0';
--		---MW<='0';
----		        IW<='0';
--		---DW<='0';
--		---AW<='0';
--		---BW<='0';
--		---RW<='0';
--		---ReW<='0';
--		Fset<='0';
                
--             when decode=>
--		---AW<='1';
--		---BW<='1';
--                --Default Zeros
--                ---PW<='0';
--                ---MR<='0';
--                ---MW<='0';
--                --IW<='0';
--                ---DW<='0';
----                AW<='0';
----                BW<='0';
--                ---RW<='0';
--                ---ReW<='0';
--		Fset<='0';

--	     when arith=>
--		---ReW<='1';
--		Fset<='1'; --Do we need to do this or check if flag should be set or not
--                --Default Zeros
--                ---PW<='0';
--                ---MR<='0';
--                ---MW<='0';
--                --IW<='0';
--                ---DW<='0';
--                ---AW<='0';
--                ---BW<='0';
--                ---RW<='0';
----                ReW<='0';
----		Fset<='0';

--             when addr=>
--		---ReW<='1';
--                --Default Zeros
--                ---PW<='0';
--                ---MR<='0';
--                ---MW<='0';
--                --IW<='0';
--                ---DW<='0';
--                ---AW<='0';
--                ---BW<='0';
--                ---RW<='0';
----                ReW<='0';
--		Fset<='0';

--	     when brn=>
--		---PW<='1';
--                --Default Zeros
----                ---PW<='0';
--                ---MR<='0';
--                ---MW<='0';
--               ---IW<='0';
--                ---DW<='0';
--                ---AW<='0';
--                ---BW<='0';
--                ---RW<='0';
--                ---ReW<='0';
--		Fset<='0';

--	     when res2RF=>
--		---RW<='1';
--                --Default Zeros
--                ---PW<='0';--##CYCLE
--                ---MR<='0';
--                ---MW<='0';
--                ---IW<='0';
--                ---DW<='0';
--                ---AW<='0';
--                ---BW<='0';
----                RW<='0';
--                ---ReW<='0';
--		Fset<='0';

--	     when mem_wr=>
--		--MW<='1';
--                --Default Zeros
--                ---PW<='0';--##CYCLE
--                ---MR<='0';
----                MW<='0';
--                ---IW<='0';
--                ---DW<='0';
--                ---AW<='0';
--                ---BW<='0';
--                ---RW<='0';
--                ---ReW<='0';
--		Fset<='0';

--	     when mem_rd=>
--		---DW<='1';
--		---MR<='1';
--                --Default Zeros
--                ---PW<='0';
----                MR<='0';
--                ---MW<='0';
--                ---IW<='0';
----                DW<='0';
--                ---AW<='0';
--                ----BW<='0';
--                ---RW<='0';
--               ---ReW<='0';
--		Fset<='0';

--	     when mem2RF=>
--		---RW<='1';
--                --Default Zeros
--                ---PW<='0';--##CYCLE
--                ---MR<='0';
--                ---MW<='0';
--                ---IW<='0';
--                ---DW<='0';
--                ---AW<='0';
--                ---BW<='0';
----                RW<='0';
--                ---ReW<='0';
--		Fset<='0';
--	     when halt=>
--                --Default Zeros
--                ---PW<='0';--##CYCLE
--                ---MR<='0';
--                ---MW<='0';
--                ---IW<='0';
--                ---DW<='0';
--                ---AW<='0';
--                ---BW<='0';
--                ---RW<='0';
--                ---ReW<='0';
--	end case;
--    end if;
    end process;
end Behavioral;