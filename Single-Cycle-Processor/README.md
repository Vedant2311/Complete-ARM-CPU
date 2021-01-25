# Single-Cycle-Processor

The entire Single Cycle processor is divided into the different modules

  * Memories: RAM and ROM
  * Display Interface
  * Clock Divider and Debouncer
  * The Instruction Decoder and ALU
  
These modules are connected in the **Top_Module.vhd** by connecting wires across the different boxes corresponding to them (by writing codes). This is supposed to be set as the Top Module in the **Xilinx Vivado** which is to be used to running the entire structure

A sample **coe** file is given which is run by this program. Please go through it once. You can see that there are different identical programs in it which are zero seperated. These programs need not be identical and can be anything. Though, there can only be eight different programs which can be loaded at one in the program. The **slide_program** input is used for this.

The **DisplayInterface.vhd** is the display interface of the module. It represents the Value which will be supposed to be viewed in the 16 LEDS in the BASYS3 FPGA. The selection of the particular value to be viewed is done by the **slide_display** input. The mapping for the **slide_display** and the Value viewed can be found in the **DisplayInterface.vhd**. 

The input **step** corresponds to the program being evaluated step-wise, while **go** corresponds to the entire program being evaluated all at once. 

The **RAM.vhd** and the **ROM.vhd** are the memory modules for the Processor. While, **Main.vhd** contains the Instruction Decoder, which takes the 32 bit instruction and obtains the Type of the instruction, obtains the registers on which the computations are to be made etc. It also contains the Arithmetic and Logical Unit which does the computations on these Register values,computes the new PC for reading the next instruction, the address where the data is supposed to be written etc. It contains the Execution cycle (Which obtains the state corresponding to the previous state and the step/go signal) and the Control Cycle (Which writes flags, registers etc as per the state)

The **clk_div.vhd** is for the clock division and the **Debouncer.vhd** is for solving the debouncing error, for having an efficient way to view the operations in real time using buttons in the FPGA. The **display.xdc** is the constraint file, having the mapping of the FPGA buttons, LEDS etc with the input and output variables of the Top Module. Go through it while trying to use the program.

This entire application can be run by generating a bit file corresponding to this in Vivado and then running it on a FPGA. Note that the coe file is to be loaded in the memories while creating them
