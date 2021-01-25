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
   type instr_class_type is (DP, DT, branch,halt,exception, unknown);
   type i_decoded_type is (ande,eor,sub,rsb, add,adc, sbc, rsc, tst, teq, cmp, cmn, orr,mov,bic, mvn,ldr_plus,ldr_minus,str_plus,str_minus,beq,bne,b, bl, bleq, blne, mul, mla, smull, smlal,umull, umlal,halt,red, swi,mrs, msr, unknown);
   --
   -- Execution control FSM
   type state_type is (initial,onestep,oneinstr,cont,done);
   -- Contorl FSM
   type control_type is (fetch,decode,shift,arith,addr,brn,halt,res2RF,mem_wr,mem_rd,mem2RF, multiply, exception_read, exception_write);
   type exception_type is (reset_type, undef_type, swi_type, irq_type, no_exception);
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
           slide_display: in std_logic_vector(5 downto 0);
             -- LED outs
            ledOut : out std_logic_vector (15 downto 0);
            IRQin : in std_logic;        
           
           Goin : in STD_LOGIC);
end Multi_Cycle_Processor;

 architecture Behavioral of Multi_Cycle_Processor is
----Component Instantiation-------
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

--ALU_Flags--
COMPONENT ALU_Flags is
    Port ( clock : in STD_LOGIC;
       Op1 : in STD_LOGIC_VECTOR (31 downto 0);
       Op2 : in STD_LOGIC_VECTOR (31 downto 0);
       Result : out STD_LOGIC_VECTOR (31 downto 0):="00000000000000000000000000000000";
       instrIn : in i_decoded_type;         
       stateIn : in control_type;
       S_bit : in std_logic;
       C_shift : in std_logic;
       --Operation : in STD_LOGIC_VECTOR (2 downto 0);    --can add more operations
       fwe : in STD_LOGIC;
       
       -- exception
       mov_spl : in std_logic;
       CPSRin : out std_logic_vector(31 downto 0);
                   SPSRin : in std_logic_vector(31 downto 0);
                  mode : in std_logic_vector(4 downto 0); 
       -- multiply
         -- Multiply
                 mulOut : in std_logic_vector(63 downto 0);
                 mult_rn : in std_logic_vector(31 downto 0);
                  mult_rn_low : in std_logic_vector(31 downto 0);
                   Result_optional : out std_logic_vector(31 downto 0);
         
       FLAGS : out STD_LOGIC_VECTOR (3 downto 0):="0000");   --Can add more 
 end COMPONENT;

--Clock divider
component clk_div is
   port(
   Clock: in std_logic;
   clk_debounce : out std_logic
   );
 end component;
 
 -- multiply
 component Multiplier is
     Port ( mul1 : in STD_LOGIC_VECTOR (31 downto 0);
            mul2 : in STD_LOGIC_VECTOR (31 downto 0);
            instrin : in i_decoded_type;
            mult_out : out STD_LOGIC_VECTOR (63 downto 0));
            
 end component;
 
 
 --Debouncer
 component Debouncer is 
    port(
     
     Reset : in std_logic;
     step : in std_logic;
     go : in std_logic;
     clk_debounce : in std_logic;
     oneinstr : in std_logic;
     IRQ : in std_logic;
     
     IRQ_CPU : out std_logic;
     oneinstr_CPU : out std_logic;
     Reset_CPU : out std_logic;
     step_CPU : out std_logic;
     go_CPU : out std_logic
    );
  end component;


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
          
          blwe : in std_logic;
                       --Outputting the values
          
           -- Multiply 
           wad_optional : in std_logic_vector(3 downto 0);
           rmul1 : in std_logic_vector(3 downto 0);
           rmul2 : in std_logic_vector(3 downto 0);
          i_type : in i_decoded_type;
          rd3 : out std_logic_vector(31 downto 0);
           wad3 : in std_logic_vector(3 downto 0);
           rd4 : out std_logic_vector(31 downto 0);
           we_optional : in std_logic;
           wd_optional : in std_logic_vector(31 downto 0);
          cpsr_i : out std_logic;
          --Exception
          fwe : in std_logic;
          flagsin : in std_logic_vector(3 downto 0);
           mode : in std_logic_vector(4 downto 0);
             cpsr_we : in std_logic;
             SPSR_we : in std_logic;        
             exception_in : in exception_type;    
             control_state : in control_type;       
             tempcpsr : in std_logic_vector(31 downto 0);
             mov_spl : in std_logic;          
            Ps : in std_logic;
            IRQ : in std_logic; 
            reset : in std_logic; 
            
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
       check15 : out std_logic_vector(31 downto 0);
       
        --Exception display
              check_CPSR : out std_logic_vector(31 downto 0);
              check_SPSR : out std_logic_vector(31 downto 0);
              check_R13_svc : out std_logic_vector(31 downto 0);
              check_R14_svc : out std_logic_vector(31 downto 0)
          
          );
end COMPONENT;

----Instruction Decoder----
COMPONENT InstructionDecoder is
    Port ( instruction : in STD_LOGIC_VECTOR(31 downto 0);
           class : out instr_class_type;
           --IW : in std_logic;
           
           -- predication
           cond : out std_logic_vector(3 downto 0);
           mov_spl : out std_logic;
           mode : in std_logic_vector(4 downto 0);
           wad : out std_logic_vector(3 downto 0); -- Multiply
           wad_optional : out std_logic_vector (3 downto 0); -- multiply
--           rn : out std_logic_vector(3 downto 0); -- Multiply
--           rn_optional : out std_logic_vector(3 downto 0); -- Multiply
           
           control_state : in control_type;
           
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
      P_bit: in std_logic;
      --multiply
      i_type: in i_decoded_type;
                
     -- Exception
         exception_out : out exception_type;
         IRQ : in std_logic;
         CPSR_I : in std_logic;
         mov_spl : in std_logic; 
      
      LD_bit : in std_logic
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
  a : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
  d : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  clk : IN STD_LOGIC;
  we : IN STD_LOGIC;
  spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
);
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
                                 
   check_CPSR : in std_logic_vector(31 downto 0);
                 check_SPSR : in std_logic_vector(31 downto 0);
                 check_R13_svc : in std_logic_vector(31 downto 0);
                 check_R14_svc : in std_logic_vector(31 downto 0);
             
    mode : in std_logic_vector(4 downto 0);
   -- Add the States input from the CPU
   
   led_Out : out std_logic_vector (15 downto 0) 
	
           );
end component;


----Constants----
    signal four: std_logic_vector(31 downto 0):="00000000000000000000000000000100";
    constant EX : std_logic_vector(19 downto 0):="00000000000000000000";
    signal S1 : std_logic_vector(23 downto 0):="000000000000000000000000";
    signal S2 : std_logic_vector(5 downto 0);
    constant Z27 : std_logic_vector(26 downto 0):="000000000000000000000000000";
----Intermmediate Registers------
    signal IR : std_logic_vector(31 downto 0):="00000000000000000000000000000000";
    signal DR : std_logic_vector(31 downto 0):="00000000000000000000000000000000";
    signal A : std_logic_vector(31 downto 0):="00000000000000000000000000000000";
    signal BB : std_logic_vector(31 downto 0):="00000000000000000000000000000000";
    signal RES : std_logic_vector(31 downto 0):="00000000000000000000000000000000";
    signal SR:std_logic_vector(31 downto 0):="00000000000000000000000000000000";

-------Mux ouputs-----
    signal Asrc1_out: std_logic_vector(31 downto 0);
    signal Asrc2_out: std_logic_vector(31 downto 0);
    signal Rsrc_out: std_logic_vector(3 downto 0);
    signal Rsrc1_out: std_logic_vector(3 downto 0);
    signal M2R_out: std_logic_vector(31 downto 0);
    signal IorD_out: std_logic_vector(11 downto 0);
    
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
    
    -- Link register
    signal BLW : std_logic := '0';
    
   -- signal op: std_logic_vector(2 downto 0);    --to be extended
    --Output From different components
    signal flag_out: std_logic_vector(3 downto 0); --0,1,2,3 = N,C,Z,V
    signal pc_out: std_logic_vector(31 downto 0);
    signal alu_out: std_logic_vector(31 downto 0);  --for PC Update
    signal mem_out: std_logic_vector(31 downto 0);  --Apply conditions to store in IR or DR
    signal roshi_out: std_logic_vector(31 downto 0);
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
    signal LD_bit: std_logic; --DO WE NEED THIS???? OR NOT CHECK LATER
    signal I_bit: std_logic;
    signal S_bit: std_logic;
    signal shift_I: std_logic;  --for specifying shift from reg or imm
    signal branch: std_logic;   --to check if branch or not
    signal Imm: std_logic_vector(31 downto 0);      --To compute Imm for DP and DT
    signal operand2 : std_logic_vector(31 downto 0);
    signal shamt : std_logic_vector(31 downto 0);
    signal C_shift: std_logic;
    --signal const: std_logic_vector(31 downto 0);
    --signal ex_offset: std_logic_vector(31 downto 0);
    --signal zex_offset: std_logic_vector(31 downto 0);
    --temporary
    
    -- Predication
     signal P_temp : std_logic := '1';
     signal cond : std_logic_vector(3 downto 0);
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
        
       --Shifter edits
       signal shift_type : std_logic_vector(1 downto 0); 
        
      -- Multiplier
       signal wad : std_logic_vector(3 downto 0);
       signal wad_optional : std_logic_vector(3 downto 0);
       signal rn : std_logic_vector(3 downto 0);  
       signal rn_optional : std_logic_vector (3 downto 0);
    
       signal mult_write : std_logic := '0';
       signal multA : std_logic_vector(31 downto 0);
       signal multB : std_logic_vector(31 downto 0);
       signal mult_result : std_logic_vector(63 downto 0);
       signal rd3 : std_logic_vector(31 downto 0);
       signal rd4: std_logic_vector(31 downto 0);
       signal Result_Optional : std_logic_vector(31 downto 0);
       signal RW_optional : std_logic := '0';
       
       -- Exception
       signal IRQ_CPU : std_logic;
       signal cpsr_i : std_logic;
       signal exception_out : exception_type := no_exception;
       signal mode :  std_logic_vector(4 downto 0) := "10000";
       signal check_CPSR : std_logic_vector(31 downto 0);
       signal check_SPSR :  std_logic_vector(31 downto 0);
       signal check_R13_svc :  std_logic_vector(31 downto 0);
       signal check_R14_svc :  std_logic_vector(31 downto 0);
       signal SPSR_we :  std_logic;
       signal cpsr_we : std_logic;
       signal mov_spl : std_logic;
       signal tempCPSR : std_logic_vector(31 downto 0);
       signal tempSPSR : std_logic_vector(31 downto 0);
              
       signal temp: std_logic;   
       signal alpha : unsigned(11 downto 0);
       signal beta : unsigned(11 downto 0) := "001111111111";    
begin
------Port mapping-----

Div: clk_div
        port map(
        
           Clock => Clockin,
           clk_debounce => clk_debounce
        );        
                  
  -- multiply
Mul: Multiplier
          port map(
          
             mul1 => multA,
             mul2 => multB,
             mult_out => mult_result,
             instrin => i_decod
          );                        
                            
Deb: Debouncer
port map(

  Reset => Resetin,
  step => Onestepin,
  go => Goin,
  clk_debounce => clk_debounce,
  oneinstr => Oneinstrin,
  IRQ => IRQin,
  
  IRQ_CPU => IRQ_CPU,
  oneinstr_CPU => oneinstr_CPU,
  Reset_CPU => Reset_CPU,
  go_CPU => go_CPU,
  step_CPU => step_CPU


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
        C_shift=>C_shift,
        Instrin=>i_decod,
        statein=>control_state,
       -- Operation=>op,
        fwe=>Fset,
        FLAGS=>flag_out,
        
        -- exception
        mov_spl => mov_spl,
        CPSRin => tempCPSR,
        SPSRin => check_SPSR,
        mode => mode,
        
        -- multiply
        mulOut => mult_result,
        mult_rn => rd4,
        mult_rn_low => rd3,
        Result_optional => Result_optional
        
        );
--Register File
RF: RegisterFile
port map(
        clock=>clockin,
        wd=>M2R_out,
        wad=> wad,--IR(15 downto 12), -- Multiply
        wad_optional => wad_optional, -- Multiply
        we =>RW,
        rad1=>Rsrc1_out,
        rad2=>Rsrc_out,
        rd1=>rd1,
        rd2=>rd2,
        pcwe=>PW,
        pc_read=>pc_out,
        pc_write=>alu_out,   --As ALU is doing PC calcualtions
        
        blwe => BLW,
        
        -- Multiply
         rmul1 => IR(3 downto 0),
         rmul2 => IR(11 downto 8),
         i_type => i_decod,
         rd3 => rd3,
         wad3 => IR(15 downto 12),
         rd4 => rd4,
         we_optional => RW_optional,
         wd_optional => Result_optional,
         spsr_we => spsr_we,
         --Exception
         fwe => Fset,
         Flagsin => flag_out,
         mode => mode, 
         cpsr_we => cpsr_we,
         control_state => control_state,
         exception_in => exception_out,
         cpsr_i => cpsr_i,
         IRQ => IRQ_cpu,
         reset => reset_cpu,
         
         tempcpsr => tempcpsr,
         mov_spl => mov_spl,
         Ps => IR(22),
         
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
                    check15 => check15,
                    
                check_CPSR => check_CPSR,
                check_SPSR => check_SPSR,
                check_R13_svc => check_R13_svc,
                check_R14_svc => Check_R14_svc

        );
        
MM: dist_mem_gen_0
        port map(
                a=>IorD_out,
                d=>BB,
                spo=>mem_out,
                clk=>clockin,
                we=>MW
                );
        
        
ID: InstructionDecoder
port map(
        instruction=>IR,        
        class=>instr_class,
        cond => cond,
        
        -- Multiply
        wad => wad,
        wad_optional => wad_optional,
        
        control_state => control_state,
--        rn => rn,
--        rn_optional => rn_optional,
        mov_spl => mov_spl,
        mode => mode,
        i_decod=>i_decod
        --IW => IW
        );
--Control FSM
C_FSM: Control_FSM
port map(
        Clock=>clockin,
        Reset=>reset_cpu,
        Green=>Green,
        Red=>Red,
        ctrlstate=>control_state,
        instr_class=>instr_class,
        P_bit => P_temp,
        
        --multiply
        i_type => i_decod,
        
        --Exception
        IRQ => IRQ_CPU,
        cpsr_i => cpsr_i,
        exception_out => exception_out,
        mov_spl => mov_spl,
        
        LD_bit=>LD_bit
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
EF: Execution_FSM
port map(
        clock=>clockin,
        Reset=> reset_cpu,
        Step=>step_cpu,
        Instr=> oneinstr_cpu,
        Go=>Go_cpu,
        
        Red=>Red,
        Green=>Green,
        control_state=>control_state,
        exstate=>exec_state
        );
        
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
                                                                                
                   check_spsr => check_spsr,
                   check_cpsr => check_cpsr,
                   check_r13_svc => check_r13_svc,
                   check_r14_svc => check_r14_svc,
                   mode => mode,
                   -- Add the States input from the CPU
                   
                   led_Out => led_out
                    
                
                
                );        
        

   -- Predication
    P_temp <= '1' when (((flag_out(2)='1') and (cond = "0000")) or ((flag_out(2)= '0') and (cond = "0001")) or ((flag_out(1) = '1') and (cond="0010")) or ((flag_out(1) = '0') and (cond = "0011")) or ((flag_out(0) = '1') and (cond = "0100")) or ((flag_out(0) = '0') and (cond = "0101")) or ((flag_out(3) = '1') and (cond = "0110")) or ((flag_out(3) = '0') and (cond = "0111")) or (((flag_out(1)='1') and (flag_out(2) = '0')) and (cond = "1000")) or ((not((flag_out(1)='1') and (flag_out(2) = '0'))) and (cond = "1001")) or (((flag_out(0)='1') xnor (flag_out(3) = '1')) and (cond = "1010")) or ((not ((flag_out(0)='1') xnor (flag_out(3)='1'))) and (cond = "1011")) or (((flag_out(2) = '0') and ((flag_out(0)='1') xnor (flag_out(3)='1'))) and (cond = "1100")) or ((not (((flag_out(0)='1') xnor (flag_out(3)='1')) and (not (flag_out(2)='1')))) and (cond = "1101")) or ((cond ="1110"))) else '0';
        
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

--Rotate and shift nad shign extension
    -- sign extension of Imm24
        S2<="000000" when IR(23) ='0' else "111111";
        --S1<="000000000000000000000000" when IR(7)='0' else "111111111111111111111111";   --Zero extension not signed!! 
        Imm<=EX&IR(11 downto 0) when instr_class = DT else --Zero extension of Imm12 for DT
             S1&IR(7 downto 0) when instr_class = DP else "00000000000000000000000000000000";-- sign extension 
        --offset<=IR(23 downto 0);
        --ex_offset<=S2&offset; 
        --zex_offset<=ex_offset(29 downto 0)&"00";
    --Rotation
        --1.shift amount for DP instructions inlcude for DT later by anding with instr_type = DP and DT
        shamt<=SR when shift_I = '1' and I_bit<='0' else --register specified for regsiter
               Z27&IR(11 downto 7) when shift_I='0' and I_bit<='0' else     --Constant specified for register
               Z27&IR(11 downto 8)&"0";         --2*Rotation for constant by appending Zero
               
         -- ##change      
        Operand2<=roshi_out when instr_class = DP and (control_state /= fetch) else Asrc2_out;       --Rotate all DP instructions ## Do we need to write this after Asrc2_out?? include DT later 

              
--Multiplexer logic
     
        IorD_out<=pc_out(13 downto 2) when IorD ='0' else RES(13 downto 2);
        Rsrc_out<=IR(3 downto 0) when Rsrc='0' else IR(15 downto 12);
      
       
       -- Multiply
        Rsrc1_out<=IR(19 downto 16) when Rsrc1='0' else IR(11 downto 8);    --give shift amt register address
        
        --Shifter edits
        shift_type <= "11" when I_bit = '1' else
                      IR(6 downto 5);
        
        M2R_out<=RES when M2R ='0' else DR;
        Asrc1_out<=pc_out when Asrc1 ='0' else A;
        Asrc2_out<=BB when Asrc2="00" else  --rotation  and shift
                    four when Asrc2="01" else
                    Imm when Asrc2="10"else  --Need to take care of rotation and constants for DP instructions
                    S2&IR(23 downto 0)&"00";--zex_offset;--(std_logic_vector(to_signed( (to_integer(signed(IR(23 downto 0)))*4),26 )))
                    

----Mux select inputs--(Should this be inside process???)
        --ldr/str and Immm/reg distinction check on basis of flag if branch or not
        LD_bit<=IR(20);
        I_bit<=IR(25);
        S_bit<=IR(20);
        shift_I<=IR(4);
        --Imm<=(not I_bit) when instr_class = DT else I_bit; --I for DP,, not I for DT
        branch<='1' when (control_state = brn) and ((i_decod = b) or (i_decod = beq and flag_out(2)='1') or (i_decod = bne and flag_out(2)='0') or (i_decod = bl) or (i_decod = bleq and flag_out(2)='1') or (i_decod = blne and flag_out(2)='0') ) else '0';
        --####WHat to do when not branching???
        IorD<='1' when control_state=mem_rd or control_state=mem_wr  else '0';  --was res to RF 
        M2R<='0' when control_state=res2RF else '1';    -- write back to RF from alu then 0 else from memory
        Rsrc<='1' when ((control_state=decode) and (I_bit='0') and((i_decod=str_plus) or (i_decod=str_minus))) else '0'; --Check when to give 1 and 0 ### also op??##what to input
        Rsrc1<='1' when control_state=shift else '0';    --TO give register specifying shift
        Asrc1<='0' when control_state=fetch or branch='1' else '1';
        Asrc2<="00" when control_state=arith and I_bit='0' else
               "01" when control_state=fetch  else   --PC increment
               "11" when branch ='1' else     --Branch instr
               "10" when (control_state=addr and I_bit='0') or (control_state=arith and I_bit='1')  else
             -- else "00"; ## create latch if not works
               "00";
        --Daring try
        PW<='1' when (control_state=fetch or branch ='1') and Green='1' else '0';
        MW<='1' when (control_state =mem_wr) and (alpha < beta) else '0';
        RW<='1' when (control_state = res2RF or control_state = mem2RF ) and   not(i_decod = cmp or i_decod = cmn or i_decod = tst or i_decod = teq  ) else '0';
        MR<='1' when (control_state =fetch or control_state =mem_rd) and (alpha < beta) else '0';
        
        IW<='1' when control_state = fetch else '0';
        DW<='1' when control_state = mem_rd else '0';
        AW<='1' when control_state = decode else '0';
        BW<='1' when control_state = decode else '0';
        ReW<='1' when control_state = arith or control_state = addr else '0';
        SW<='1' when control_state = shift else '0';   --to get register specified shift amount
        Fset<='1' when S_bit ='1' and control_state = arith else '0'; -- AFlags set by DP instructions when S bit is 1
        BLW <= '1' when (branch = '1' and (i_decod = bl or i_decod = bleq or i_decod = blne)) else '0';
        
        -- Multiply
        mult_write<='1' when control_state = multiply else '0'; 
        RW_optional <= '1' when (control_state = res2RF) and ((i_decod = umlal) or (i_decod = smlal) or (i_decod = umull) or (i_decod = smull)) else '0'; 
        
--Logic for Operands and offset calculation
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
 
-- --Get offset for DT and branch
-- Offset <= to_integer(unsigned(Imm12)) when instr_class = DT and U_bit = '1' else
--           to_integer(unsigned(Imm12)) when instr_class = DT and U_bit = '0' else
--           to_integer(signed(Imm24)) when instr_class = branch else
--           0;
-------Orange signals control logic--------
         ledout <= led_out;
    
         -- Exception
         mode <= "10011" when ((exception_out = reset_type and control_state = fetch) or (exception_out = undef_type and control_state = exception_read) or (exception_out = swi_type and control_state = exception_read) or (exception_out = irq_type and control_state = exception_read)) else
                 "10000" when mov_spl = '1' and control_state = fetch else
                 "10011" when i_decod=msr and control_state = fetch and (check_CPSR(4 downto 0) = "10011") else
                 "10000" when i_decod=msr and control_state = fetch and (check_CPSR(4 downto 0) = "10000") else
                  mode; 
                  
         cpsr_we <= '1' when ((exception_out = reset_type and control_state = fetch) or (exception_out = undef_type and control_state = exception_write) or (exception_out = swi_type and control_state = exception_write) or (exception_out = irq_type and control_state = exception_write))  else
                    '0';


         SPSR_we <= '1' when control_state = exception_read and (exec_state /= done and exec_state /= initial) else
                    '0';
         
         
         --checking
         temp <= '1' when check15="00000000000000000000010000000000" else '0';
         
         alpha <= unsigned(IorD_out);
         
         
         
    process(clockin,resetin)
    begin
        if(falling_edge(clockin)) then
            if IW='1' then IR<=mem_out; 
            elsif DW='1' then DR<=mem_out; end if;
            if AW='1' then A<=rd1; end if;
            if BW='1' then BB<=rd2; end if;
            if ReW='1' then RES<=ALU_out; end if;
            if SW='1' then SR<=rd1; end if;
            
            -- multiply
            if mult_write = '1' then multA <= rd1; multB <= rd2; end if;
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