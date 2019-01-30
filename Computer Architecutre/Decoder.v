`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Shahzor Ahmad and Rajesh Panicker  
-- 
-- Create Date: 09/23/2015 06:49:10 PM
-- Module Name: Decoder
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: Decoder Module
-- 
-- Dependencies: NIL
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
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

module Decoder(
    input [3:0] Rd,
    input [1:0] Op,
    input [5:0] Funct,
    output PCS,
    output RegW,
    output MemW,
    output MemtoReg,
    output ALUSrc,
    output [1:0] ImmSrc,
    output [1:0] RegSrc,
    output NoWrite,
    output [3:0] ALUControl,
    output [2:0] FlagW,
    output SignalA,
    output SignalB
    );
    
    wire ALUOp;
	wire Branch;
    reg [9:0] controls ;
    //<extra signals, if any>
    
	assign Branch = Op[1] & ~Op[0];
	
	assign PCS = (Rd==15 & RegW) | Branch;
	assign RegW = (~Op[0] & ~Op[1]) | (~Op[1] & Op[0] & Funct[0]);
	assign MemW = ~Op[1] & Op[0] & ~Funct[0];
	assign MemtoReg = Op[0] & ~Op[1] & Funct[0] ;
	assign ALUSrc = (Op == 2'b00);
	assign ImmSrc[1] = Op[1] & ~Op[0];
	assign ImmSrc[0] = Op[0] & ~Op[1];
	assign RegSrc[0] = Op[1] & ~Op[0];
    assign RegSrc[1] = ~Op[1] & Op[0] & ~Funct[0]; 
	assign NoWrite = (Funct[4:3] == 2'b10);
	
	assign ALUControl =  (Op[1:0] == 2'b01) ? (Funct[3] ? 4'b0100 : 4'b0010) : 
	                                           ((Op[1:0] == 2'b00) ? Funct[4:1] : 4'b0000);

	assign ALUOp = ~Op[0] & ~Op[1]; //FOR data processing 
    assign FlagW[2:0] = ALUOp ? (((Funct[4:1] > 4'b0001 & Funct[4:1] < 4'b1000)||
                                    (Funct[4:1] > 4'b1001 & Funct[4:1] < 4'b1100)) ? 3'b111 : 3'b110) : 3'b000;
	
	assign SignalA = ~Op[0] & ~Op[1] & Funct[5];
	assign SignalB = Op[0] ^ Funct[5];
endmodule





