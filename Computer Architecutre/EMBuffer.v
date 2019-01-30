`timescale 1ns / 1ps

module EMBuffer(
	input CLK,
	input PCSrcE,
	input RegWriteE,
	input MemWriteE,
	input MemtoRegE,
	input[31:0] ALUResultE,
	input[31:0] WriteDataE,
	input[31:0] RD2E,
	input[3:0] WA3E,
	input[3:0] RA1E,
	input[3:0] RA2E,
					
	output reg PCSrcM = 0,
	output reg RegWriteM = 0,
	output reg MemWriteM = 0,
	output reg MemtoRegM = 0,
	output reg [31:0] ALUOutM = 0,
	output reg [31:0] WriteDataM = 0,
	output reg [31:0] RD2M = 0,
	output reg [3:0] WA3M = 0,
	output reg [3:0] RA1M = 0,
	output reg [3:0] RA2M = 0
	);
	
	always@(posedge CLK) begin
	PCSrcM <= PCSrcE;
	RegWriteM <= RegWriteE;
	MemWriteM <= MemWriteE;
	MemtoRegM <= MemtoRegE;
	ALUOutM <= ALUResultE;
	WriteDataM <= WriteDataE;
	RD2M <= RD2E;
	WA3M <= WA3E;
	RA1M <= RA1E;
	RA2M <= RA2E;
	end
	
	endmodule