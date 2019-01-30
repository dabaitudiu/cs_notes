`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/01 20:51:16
// Design Name: 
// Module Name: DEBuffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module DEBuffer(
	input CLK,
	input FlushE,
	input PCSD,
	input RegWD,
	input MemWD,
	input[2:0] FlagWD,
	input[3:0] ALUControlD,
	input MemtoRegD,
	input SignalAD,
	input SignalBD,
	input NoWriteD,
	input [7:0]SubInstrD,
	input[3:0] Cond,
	input[31:0] RD1,
	input[31:0] RD2,
	input[31:0] Rs,
	input[3:0] WA3D,
	input[31:0] ExtImm,
	input[3:0] A1,
	input[3:0] A2,
	
	output reg PCSE = 0,
	output reg RegWE = 0,
	output reg MemWE = 0,
	output reg [2:0] FlagWE = 0,
	output reg [3:0] ALUControlE = 0,
	output reg MemtoRegE = 0,
	output reg SignalAE = 0,
	output reg SignalBE = 0,
	output reg NoWriteE = 0,
	output reg [7:0] SubInstrE = 0,
	output reg [3:0] CondE = 0,
	output reg [31:0] RD1E = 0,
	output reg [31:0] RD2E = 0,
	output reg [31:0] RsE = 0,
	output reg [3:0] WA3E = 0,
	output reg [31:0] ExtImmE = 0,
	output reg [3:0] RA1E = 0,
	output reg [3:0] RA2E = 0
	);
	
	
	
	always@(posedge CLK) begin
	PCSE <= FlushE ? 0 : PCSD;
	RegWE <= FlushE ? 0 : RegWD;
	MemWE <= FlushE ? 0 : MemWD;
	FlagWE <= FlushE ? 0 : FlagWD;
	ALUControlE <= ALUControlD;
	MemtoRegE <= MemtoRegD;
	SignalAE <= SignalAD;
	SignalBE <= SignalBD;
	NoWriteE <= NoWriteD;
	SubInstrE <= SubInstrD;
	CondE <= Cond;
	RD1E <= RD1;
	RD2E <= RD2;
	RsE <= Rs;
	WA3E <= WA3D;
	ExtImmE<= ExtImm;
	RA1E <= A1;
	RA2E <= A2;
	end
	
endmodule
