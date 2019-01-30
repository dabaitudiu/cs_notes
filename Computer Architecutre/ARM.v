`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: Li Zhenhan
-- 
-- Create Date: 2017/11/01 20:51:57
-- Module Name: ARM
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: ARM Module
-- 
-- Dependencies: NIL
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: The interface SHOULD NOT be modified. The implementation can be modified
-- 
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v)	acknowledge that the program was written based on the microarchitecture described in the book Digital Design and Computer Architecture, ARM Edition by Harris and Harris;
--		(vi) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vii) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
*/

//-- R15 is not stored
//-- Save waveform file and add it to the project
//-- Reset and launch simulation if you add interal signals to the waveform window

module ARM(
    input CLK,
    input RESET,
    //input Interrupt,  // for optional future use
    input [31:0] Instr,
    input [31:0] ReadData,
    output MemWriteM,
    output [31:0] PCF,
    output [31:0] ALUOutM,
    output [31:0] WriteData
    );
    
	wire [31:0] InstrF;
	wire [31:0] InstrD;
	wire [31:0] WriteDataE;
	wire [31:0] WriteDataM;
	wire [31:0] ReadDataW;
	wire [31:0] ALUOutW;
    // RegFile signals
    //wire CLK ;
    wire WE3 ;
    wire [3:0] A1 ;
    wire [3:0] A2 ;
    wire [3:0] A3 ;
    wire [3:0] A4 ;
	wire [3:0] RA1E;
	wire [3:0] RA2E;
	wire [3:0] RA1M;
	wire [3:0] RA2M;
    wire [31:0] WD3 ;
    wire [31:0] R15 ;
    wire [31:0] RD1 ;
	wire [31:0] RD1E;
    wire [31:0] RD2 ;
	wire [31:0] RD2E ;
	wire [31:0] RD2M;
    wire [31:0] Rs;
	wire [31:0] RsE ;
    
	wire [3:0] WA3D ;
	wire [3:0] WA3E ;
	wire [3:0] WA3M ;
	wire [3:0] WA3W ;
	
    // Extend Module signals
    wire [1:0] ImmSrc ;
    wire [23:0] InstrImm ;
    wire [31:0] ExtImm ;
	wire [31:0] ExtImmE ;
    
    // Decoder signals
    wire [3:0] Rd ;
    wire [1:0] Op ;
    wire [5:0] Funct ;
    //wire PCS ;
    //wire RegW ;
    //wire MemW ;
	wire MemtoRegD ;
	wire MemtoRegE ;
	wire MemtoRegM ;
	wire MemtoRegW ;
    wire ALUSrc ;
    //wire [1:0] ImmSrc ;
	wire [1:0] RegSrcD;
    //wire NoWriteD ;
    //wire [1:0] ALUControlD ;
    //wire [1:0] FlagW ;
    wire SignalAD;
	wire SignalAE;
    wire SignalBD;
	wire SignalBE;
    
    // CondLogic signals
    //wire CLK ;
    wire PCSD ;
	wire PCSE ;
	
	wire RegWD;
	wire RegWE;
    wire NoWriteD ;
	wire NoWriteE ;
	wire MemWD ;
	wire MemWE ;
    wire [2:0] FlagWD ;
	wire [2:0] FlagWE ;
    wire [3:0] Cond ;
	wire [3:0] CondE ;
    //wire [3:0] ALUFlags,
    wire PCSrc ;
	wire PCSrcE ;
	wire PCSrcM ;
	wire PCSrcW ;

	wire RegWriteE ;
	wire RegWriteM ;
	wire RegWriteW ;
    wire MemWriteE ;
       
    // Shifter signals
    wire [1:0] Sh ;
    wire [7:0] SubInstrD ;
	wire [7:0] SubInstrE ;
    wire [31:0] RS2;
    wire [31:0] ShInE ;
	wire [31:0] ShOutE;
	wire Cout;
    
    // ALU signals
    wire [31:0] Src_A ;
	wire [31:0] Src_AE;
    wire [31:0] Src_B ;
	wire [31:0] Src_BE;
    wire [3:0] ALUControlD ;
	wire [3:0] ALUControlE ;
    wire [31:0] ALUResultE ;
	wire [31:0] ALUOutM ;
    wire [3:0] ALUFlags ;
    
    // ProgramCounter signals
    //wire CLK ;
    //wire RESET ;
    wire WE_PC ;    
    wire [31:0] PC_IN ;
    //wire [31:0] PC ; 
        
    // Other internal signals here
    wire [31:0] PCPlus4 ;
    wire [31:0] PCPlus8 ;
    wire [31:0] Result ;
	wire [31:0] ResultW ;
	wire carryFlag;
	
	
	//Hazard Unit 
	wire Match_1E_M;
	wire Match_2E_M;
	wire Match_1E_W;
	wire Match_2E_W;
	wire Match_12D_E;
	wire ldrstall;
	wire [1:0] ForwardAE;
	wire [1:0] ForwardBE;
	wire ForwardM;
	wire StallF ;
	wire StallD ;
	wire FlushE ;
	wire FlushD ;
    
    // datapath connections here
	assign InstrF = Instr;
    assign WE_PC = 1 ; // Will need to control it for multi-cycle operations (Multiplication, Division) and/or Pipelining with hazard hardware.

	//Program Counter
	assign PCPlus4 = PCF + 4;
	assign PCPlus8 = PCPlus4 + 4;
//	assign PC_IN = PCSrcW ? ResultW : PCPlus4;
    assign PC_IN = PCSrcE ? ALUResultE : PCPlus4;	
	//register file
	assign A1 = RegSrcD[0] ? 4'b1111 : InstrD[19:16];
	assign A2 = RegSrcD[1] ? InstrD[15:12] : InstrD[3:0];
	assign A3 = WA3W;
	assign WA3D = InstrD[15:12];
	assign A4 = InstrD[11:8];
	assign WD3 = ResultW;
	assign R15 = PCPlus4;
	assign WE3 = RegWriteW;
	
	
	//Extend
	assign InstrImm = InstrD[23:0];
	
	//shifter
	assign ShInE = SignalAE ? ExtImmE : ((ForwardBE == 2'b00)? RD2E : ((ForwardBE == 2'b01)? ResultW : ALUOutM));
	assign SubInstrD = InstrD[11:4];
	
	//ALU
	assign Src_AE = ((ForwardAE == 2'b00)? RD1E : ((ForwardAE == 2'b01)? ResultW : ALUOutM));
	assign Src_BE = SignalBE ? ExtImmE : ShOutE;
	
	//Control Unit
	assign Cond = InstrD[31:28];
	assign Op = InstrD[27:26];
	assign Funct = InstrD[25:20];
	assign Rd = InstrD[15:12];
	
	//ALUResult
    assign ResultW = MemtoRegW ? ReadDataW : ALUOutW;
    assign WriteDataE = ShInE;
    assign carryFlag = ALUFlags[1];
	assign WriteData = ForwardM ? ResultW : WriteDataM;
	
	//Hazard Unit
	assign Match_1E_M = (RA1E == WA3M);
	assign Match_2E_M = (RA2E == WA3M);
	assign Match_1E_W = (RA1E == WA3W);
	assign Match_2E_W = (RA2E == WA3W);
	assign ForwardAE = (Match_1E_M & RegWriteM) ? 2'b10 : ((Match_1E_W & RegWriteW) ? 2'b01 : 2'b00);
	assign ForwardBE = (Match_2E_M & RegWriteM) ? 2'b10 : ((Match_2E_W & RegWriteW) ? 2'b01 : 2'b00);
	assign ForwardM = (RD2M == WA3W) & MemWriteM & MemtoRegW & RegWriteW;
	assign Match_12D_E = (A1 == WA3E) || (A2 == WA3E);
	assign ldrstall = Match_12D_E & MemtoRegE;
	assign StallF = ldrstall;
	assign StallD = ldrstall;
	assign FlushD = PCSrcE;
	assign FlushE = ldrstall || PCSrcE;

	//Instantiate F-D Buffer
	FDBuffer FDBuffer1(
					CLK, 
					StallD,
					FlushD,
					InstrF,
					InstrD);
	
	
    // Instantiate RegFile
    RegFile RegFile1( 
                    CLK,
                    WE3,
                    A1,
                    A2,
                    A3,
                    A4,
                    WD3,
                    R15,
                    RD1,
                    RD2,
                    Rs     
                );
				
	
				
				
				
                
     // Instantiate Extend Module
    Extend Extend1(
                    ImmSrc,
                    InstrImm,
                    ExtImm
                );
                
    // Instantiate Decoder
    Decoder Decoder1(
                    Rd,
                    Op,
                    Funct,
                    PCSD,
                    RegWD,
                    MemWD,	
                    MemtoRegD,
                    SignalBD,
                    ImmSrc,
                    RegSrcD,
                    NoWriteD,
                    ALUControlD,
                    FlagWD,
                    SignalAD
                );
				
	// Instantiate D-E Buffer			
	DEBuffer DEBuffer1(
					CLK,
					FlushE,
					PCSD,
					RegWD,
					MemWD,
					FlagWD,
					ALUControlD,
					MemtoRegD,
					SignalAD,
					SignalBD,
					NoWriteD,
					SubInstrD,
					Cond,
					RD1,
					RD2,
					Rs,
					WA3D,
					ExtImm,
					A1,
					A2,
					
					PCSE,
					RegWE,
					MemWE,
					FlagWE,
					ALUControlE,
					MemtoRegE,
					SignalAE,
					SignalBE,
					NoWriteE,
					SubInstrE,
					CondE,
					RD1E,
					RD2E,
					RsE,
					WA3E,
					ExtImmE,
					RA1E,
					RA2E
					);
					
				
				
                                
    // Instantiate CondLogic
    CondLogic CondLogic1(
                    CLK,
                    PCSE,
                    RegWE,
                    NoWriteE,
                    MemWE,
                    FlagWE,
                    CondE,
                    ALUFlags,
                    PCSrcE,
                    RegWriteE,
                    MemWriteE
                );
				
				
                
    // Instantiate Shifter        
    Shifter Shifter1(
                    SubInstrE,
                    ShInE,
                    RsE,
                    SignalAE,
                    ShOutE,
					Cout
                );
                
				
				
	// Instantiate E-M Buffer
	EMBuffer EMBuffer1(
					CLK,
					PCSrcE,
					RegWriteE,
					MemWriteE,
					MemtoRegE,
					ALUResultE,
					WriteDataE,
					RD2E,
					WA3E,
					RA1E,
					RA2E,
					
					PCSrcM,
					RegWriteM,
					MemWriteM,
					MemtoRegM,
					ALUOutM,
					WriteDataM,
					RD2M,
					WA3M,
					RA1M,
					RA2M
					);
				
	
    // Instantiate ALU        
    ALU ALU1(
                    Src_AE,
                    Src_BE,
                    carryFlag,
                    ALUControlE,
                    ALUResultE,
                    ALUFlags
                );                
    
	//Instantiate M-W Buffer
	MWBuffer MWBuffer1(
					CLK,
					PCSrcM,
					RegWriteM,
					MemtoRegM,
					ReadData,
					ALUOutM,
					WA3M,
					
					PCSrcW,
					RegWriteW,
					MemtoRegW,
					ReadDataW,
					ALUOutW,
					WA3W
					);
			
	
	
	
    // Instantiate ProgramCounter    
    ProgramCounter ProgramCounter1(
                    CLK,
					StallF,
                    RESET,
                    WE_PC,    
                    PC_IN,
                    PCF  
                );                             
endmodule








