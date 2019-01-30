`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS
-- Engineer: (c) Shahzor Ahmad and Rajesh Panicker  
-- 
-- Create Date:   21:06:18 24/09/2015
-- Design Name: 	TOP (ARM Wrapper)
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool versions: Vivado 2015.2
-- Description: Top level module - wrapper for ARM processor
--
-- Dependencies: Uses uart.vhd by (c) Peter A Bennett
--
-- Revision: 
-- Revision 0.01
-- Additional Comments: See the notes below. The interface as well as implementation can be modified
----------------------------------------------------------------------------------
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vi) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
*/

module TOP
    #(
        parameter N_LEDs_OUT = 8, // Number of LEDs displaying Result. LED[15 : 15-N_LEDs_OUT+1]. 8 by default
                                        // LED[15-N_LEDs_OUT] shows the divided clock. 
                                        // LED[15-N_LEDs_OUT-1 : 0] showing the PC[8:2].
        parameter N_DIPs = 16,    // Number of DIPs. 16 by default
        parameter N_PBs = 4       // Number of PushButtons. 4 by default
                                        // Order [3 : 0] -> BTNU, BTNL, BTNR, BTND.
                                        // Note that BTNC is used as PAUSE
    )     
    (
        input   [N_DIPs-1 : 0]  DIP,    // DIP switch inputs. Not debounced.
        input   [N_PBs-1 : 0]   PB,     // PB switch inputs. Not debounced.
        output  [15:0]          LED,    // LEDs.
            // [15 : 8] mapped to the address 0x00000C00
            // [7] showing the divided clock
            // [6 : 0] showing PC[8 : 2]
        output  TX,                     
        input   RX,
        input   PAUSE,                  // Pause -> BTNC (Centre push button)
        input   RESET,                  // Reset -> CPU_RESET (Red push button). ACTIVE LOW. Set it to 1 for simulation
        input   CLK_undiv               // 100MHz clock. Converted to a lower frequency using CLK_DIV_BLOCK before use.
    );
    
    // ----------------------------------------------------------------
    //      Constants
    // ----------------------------------------------------------------
    localparam  CLK_DIV_BITS = 5'd1 ; // 26 for a clock of the order of 1Hz. >>>>>>>>>>>>>>>>>>>>>>>>>> Important : Use 5'd1 for simulation and 5'd26 for synthesis. <<<<<<<<<<<<<<<<<<<<<<<<<<<<
    // 1 for a 50MHz clock.
    // See the notes in CLK_DIV_BLOCK for SIMULATION or for obtaining a 100MHz clock frequency, 
        
    localparam  BAUD_RATE         = 32'd115200 ;
    localparam  CLOCK_FREQUENCY   = 32'd50000000 ;
    
    //----------------------------------------------------------------
    // ARM signals
    //----------------------------------------------------------------
    //wire RESET,
    wire [31:0] Instr ;
    reg [31:0]  ReadData ;
    wire        MemWrite ;
    wire [31:0] PC ;
    wire [31:0] ALUResult ;
    wire [31:0] WriteData ;
    
    //----------------------------------------------------------------
    // Others signals
    //----------------------------------------------------------------
    wire dec_DATA_CONST, dec_DATA_VAR, dec_LED, dec_DIP, dec_CONSOLE, dec_PB ; // data memory address decoding
    wire CLK ;           // divided (low freq) clock (change to wire if not using CLK_DIV_BLOCK)
    wire RESET_EXT, RESET_INT, RESET_EFF ;    // effective reset
    reg [7:0] LED_buff ; // data memory-mapped part of LED
    
    
    //----------------------------------------------------------------
    // Declare Memories
    //  - each memory contains 128 words
    //----------------------------------------------------------------
    reg   [31:0]  INSTR_MEM        [0:127] ; // instruction memory
    reg   [31:0]  DATA_CONST_MEM   [0:127] ; // data (constant) memory
    reg   [31:0]  DATA_VAR_MEM     [0:127] ; // data (variable) memory
    

    //----------------------------------------------------------------
    // Instruction Memory
    //----------------------------------------------------------------
    integer i;

 
    //----------------------------------------------------------------
    // Instruction Memory
    //----------------------------------------------------------------
    initial begin
                INSTR_MEM[0] = 32'hE59F11F8; 
                INSTR_MEM[1] = 32'hE59F2234; 
                INSTR_MEM[2] = 32'hE59F3224; 
                INSTR_MEM[3] = 32'hE0024003; 
                INSTR_MEM[4] = 32'hE5814000; 
                INSTR_MEM[5] = 32'hE59F3220; 
                INSTR_MEM[6] = 32'hE0024003; 
                INSTR_MEM[7] = 32'hE5814000; 
                INSTR_MEM[8] = 32'hE59F320C; 
                INSTR_MEM[9] = 32'hE0224003; 
                INSTR_MEM[10] = 32'hE5814000; 
                INSTR_MEM[11] = 32'hE59F31F8; 
                INSTR_MEM[12] = 32'hE0424003; 
                INSTR_MEM[13] = 32'hE5814000; 
                INSTR_MEM[14] = 32'hE0434002; 
                INSTR_MEM[15] = 32'hE5814000; 
                INSTR_MEM[16] = 32'hE0824003; 
                INSTR_MEM[17] = 32'hE5814000; 
                INSTR_MEM[18] = 32'hE59F21FC; 
                INSTR_MEM[19] = 32'hE59F31FC; 
                INSTR_MEM[20] = 32'hE3E05000; 
                INSTR_MEM[21] = 32'hE3A06001; 
                INSTR_MEM[22] = 32'hE3A07002; 
                INSTR_MEM[23] = 32'hE0854006; 
                INSTR_MEM[24] = 32'hE0A64007; 
                INSTR_MEM[25] = 32'hE5814000; 
                INSTR_MEM[26] = 32'hE0854006; 
                INSTR_MEM[27] = 32'hE0C74006; 
                INSTR_MEM[28] = 32'hE5814000; 
                INSTR_MEM[29] = 32'hE0C74006; 
                INSTR_MEM[30] = 32'hE5814000; 
                INSTR_MEM[31] = 32'hE0854006; 
                INSTR_MEM[32] = 32'hE0E64007; 
                INSTR_MEM[33] = 32'hE5814000; 
                INSTR_MEM[34] = 32'hE0E64007; 
                INSTR_MEM[35] = 32'hE5814000; 
                INSTR_MEM[36] = 32'hE3A02020; 
                INSTR_MEM[37] = 32'hE3A0300A; 
                INSTR_MEM[38] = 32'hE3A0400F; 
                INSTR_MEM[39] = 32'hE31400C4; 
                INSTR_MEM[40] = 32'h00824003; 
                INSTR_MEM[41] = 32'hE5814000; 
                INSTR_MEM[42] = 32'hE3A0400C; 
                INSTR_MEM[43] = 32'hE314000C; 
                INSTR_MEM[44] = 32'h00824003; 
                INSTR_MEM[45] = 32'hE5814000; 
                INSTR_MEM[46] = 32'hE3A0400C; 
                INSTR_MEM[47] = 32'hE334000B; 
                INSTR_MEM[48] = 32'h00824003; 
                INSTR_MEM[49] = 32'hE5814000; 
                INSTR_MEM[50] = 32'hE334000C; 
                INSTR_MEM[51] = 32'h00824003; 
                INSTR_MEM[52] = 32'hE5814000; 
                INSTR_MEM[53] = 32'hE354002A; 
                INSTR_MEM[54] = 32'h03A04007; 
                INSTR_MEM[55] = 32'hE5814000; 
                INSTR_MEM[56] = 32'hE3540007; 
                INSTR_MEM[57] = 32'h03A0400A; 
                INSTR_MEM[58] = 32'hE5814000; 
                INSTR_MEM[59] = 32'hE3844005; 
                INSTR_MEM[60] = 32'hE5814000; 
                INSTR_MEM[61] = 32'hE3C44009; 
                INSTR_MEM[62] = 32'hE5814000; 
                INSTR_MEM[63] = 32'hE3E040EE; 
                INSTR_MEM[64] = 32'hE5814000; 
                INSTR_MEM[65] = 32'hE3A03002; 
                INSTR_MEM[66] = 32'hE3A04E3F; 
                INSTR_MEM[67] = 32'hE5814000; 
                INSTR_MEM[68] = 32'hE3A04007; 
                INSTR_MEM[69] = 32'hE1A05314; 
                INSTR_MEM[70] = 32'hE5815000; 
                INSTR_MEM[71] = 32'hE3A0211F; 
                INSTR_MEM[72] = 32'hE3A0601B; 
                INSTR_MEM[73] = 32'hE0165312; 
                INSTR_MEM[74] = 32'hE2A55000; 
                INSTR_MEM[75] = 32'hE5815000; 
                INSTR_MEM[76] = 32'hE59F80E4; 
                INSTR_MEM[77] = 32'hE59F10C4; 
                INSTR_MEM[78] = 32'hE3A02003; 
                INSTR_MEM[79] = 32'hE3A0400D; 
                INSTR_MEM[80] = 32'hE5812000; 
                INSTR_MEM[81] = 32'hE5882000; 
                INSTR_MEM[82] = 32'hE3A0601F; 
                INSTR_MEM[83] = 32'hE0867002; 
                INSTR_MEM[84] = 32'hE5983000; 
                INSTR_MEM[85] = 32'hE0045003; 
                INSTR_MEM[86] = 32'hE5815000; 
                INSTR_MEM[87] = 32'hEAFFFFFE; 
                for(i = 88; i < 128; i = i+1) begin 
                    INSTR_MEM[i] = 32'h0; 
                end
    end
    
    //----------------------------------------------------------------
    // Data (Constant) Memory
    //----------------------------------------------------------------
    initial begin
                DATA_CONST_MEM[0] = 32'h00000C00; 
                DATA_CONST_MEM[1] = 32'h00000C04; 
                DATA_CONST_MEM[2] = 32'h00000C08; 
                DATA_CONST_MEM[3] = 32'h00000C0C; 
                DATA_CONST_MEM[4] = 32'h00000C10; 
                DATA_CONST_MEM[5] = 32'hC0000000; 
                DATA_CONST_MEM[6] = 32'h00000004; 
                DATA_CONST_MEM[7] = 32'h00000800; 
                DATA_CONST_MEM[8] = 32'h00000804; 
                DATA_CONST_MEM[9] = 32'h00000808; 
                DATA_CONST_MEM[10] = 32'h00000000; 
                DATA_CONST_MEM[11] = 32'h00000003; 
                DATA_CONST_MEM[12] = 32'h00000004; 
                DATA_CONST_MEM[13] = 32'h00000005; 
                DATA_CONST_MEM[14] = 32'h00000007; 
                DATA_CONST_MEM[15] = 32'h00000009; 
                DATA_CONST_MEM[16] = 32'h0000000A; 
                DATA_CONST_MEM[17] = 32'h0000000E; 
                DATA_CONST_MEM[18] = 32'h0000000F; 
                DATA_CONST_MEM[19] = 32'h0000080C; 
                DATA_CONST_MEM[20] = 32'h00000810; 
                DATA_CONST_MEM[21] = 32'h6C6C6548; 
                DATA_CONST_MEM[22] = 32'h6F57206F; 
                DATA_CONST_MEM[23] = 32'h21646C72; 
                DATA_CONST_MEM[24] = 32'h00212121; 
                for(i = 25; i < 128; i = i+1) begin 
                    DATA_CONST_MEM[i] = 32'h0; 
                end
    end


    //----------------------------------------------------------------
    // Instantiate the processor
    //----------------------------------------------------------------
    ARM ARM1(
            CLK,
            RESET_EFF,
            //Interrupt, 
            Instr,
            ReadData,
            MemWrite,
            PC,
            ALUResult,
            WriteData
        );
    
    //----------------------------------------------------------------
    // Debug LEDs
    //----------------------------------------------------------------            
    assign LED[15-N_LEDs_OUT-1 : 0] = PC[15-N_LEDs_OUT+1 : 2] ; // debug showing PC[8 : 2]
    assign LED[15-N_LEDs_OUT] = CLK ; // debug showing clock on LED(15)        
    assign LED[15 : 15-N_LEDs_OUT+1] = LED_buff ; // data memory-mapped LED

    //----------------------------------------------------------------
    // Reset Logic
    //----------------------------------------------------------------	
    assign RESET_EXT = ~RESET ;                    // CPU_RESET is active low. 
    assign RESET_EFF = RESET_INT | RESET_EXT ;
    assign RESET_INT = 0 ; 	                       // internal reset, for future use.
    
    //----------------------------------------------------------------
    // Data memory address decoding
    //----------------------------------------------------------------
    assign dec_DATA_CONST  = ( (ALUResult >= 32'h00000200) & (ALUResult <= 32'h000003FC) ) ? 1 : 0 ;
    assign dec_DATA_VAR    = ( (ALUResult >= 32'h00000800) & (ALUResult <= 32'h000009FC) ) ? 1 : 0 ;
    assign dec_LED         = ( ALUResult == 32'h00000C00 ) ? 1 : 0 ;
    assign dec_DIP         = ( ALUResult == 32'h00000C04 ) ? 1 : 0 ;
    assign dec_PB          = ( ALUResult == 32'h00000C08 ) ? 1 : 0 ;
    assign dec_CONSOLE     = ( ALUResult == 32'h00000C0C ) ? 1 : 0 ;
    
    //----------------------------------------------------------------
    // Data memory read
    //----------------------------------------------------------------
    always@( * ) begin
        if(dec_DIP)
            ReadData = { {31-N_DIPs+1{1'b0}}, DIP } ; 
        else if(dec_PB)
            ReadData = { {31-N_PBs+1{1'b0}}, PB } ; 
        else if(dec_DATA_VAR)
            ReadData = DATA_VAR_MEM[ALUResult[8:2]] ; 
        else if(dec_DATA_CONST)
            ReadData = DATA_CONST_MEM[ALUResult[8:2]] ; 
        else 
            ReadData = 32'h0 ; 
    end
    
    //----------------------------------------------------------------
    // Instruction memory read
    //----------------------------------------------------------------
    assign Instr = ( (PC >= 32'h00000000) & (PC <= 32'h000001FC) ) ? // To check if address is in the valid range, assuming 128 word memory. Also helps minimize warnings
                     INSTR_MEM[PC[8:2]] : 32'h00000000 ; 
              
    
    //----------------------------------------------------------------
    // Data Memory-mapped LED write
    //----------------------------------------------------------------
    always@(posedge CLK) begin
        if(RESET_EXT)
            LED_buff <= 0 ;
        else if( MemWrite & dec_LED ) 
            LED_buff <= WriteData[N_LEDs_OUT-1 : 0] ;
    end
    
    //----------------------------------------------------------------
    // Data Memory write
    //----------------------------------------------------------------
    always@(posedge CLK) begin
        if( MemWrite & dec_DATA_VAR ) 
            DATA_VAR_MEM[ALUResult[8:2]] <= WriteData ;
    end
    
    
    
    // ----------------------------------------------------------------
    // Clock divider
    // ----------------------------------------------------------------
     //assign CLK = CLK_undiv ; 
     //assign CLK_uart = CLK_undiv;
    // IMPORTANT : >>> uncomment the previous lines and comment out the rest of the lines
    //             >>> for obtaining a 100MHz clock frequency. Make sure CLOCK_FREQUENCY is set to 100000000  
    
    assign CLK_uart = clk_counter[0];
    assign CLK = clk_counter[CLK_DIV_BITS-1] ;
    reg [CLK_DIV_BITS-1 : 0] clk_counter = 0 ;
    always@( posedge CLK_undiv ) begin : CLK_DIV_BLOCK
        if( ~PAUSE ) begin
            clk_counter <= clk_counter + 1 ;                
        end
    end
    
endmodule
























