`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/01 20:51:57
// Design Name: 
// Module Name: MWBuffer
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

module MWBuffer (
	input CLK,
	input PCSrcM,
	input RegWriteM,
	input MemtoRegM,
	input[31:0] ReadData,
	input[31:0] ALUOutM,
	input[3:0] WA3M,
					
	output reg PCSrcW = 0,
	output reg RegWriteW = 0,
	output reg MemtoRegW = 0,
	output reg [31:0] ReadDataW = 0,
	output reg [31:0] ALUOutW = 0,
	output reg [3:0] WA3W = 0
	);
	
	always@(posedge CLK) begin
	PCSrcW <= PCSrcM;
	RegWriteW <= RegWriteM;
	MemtoRegW <= MemtoRegM;
	ReadDataW <= ReadData;
	ALUOutW <= ALUOutM;
	WA3W <= WA3M;
	end
	
	endmodule
