`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/01 20:50:42
// Design Name: 
// Module Name: FDBuffer
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


module FDBuffer(
	input CLK,
	input StallD,
	input FlushD,
	input[31:0] Instr,
	output reg [31:0] InstrD
	);

	always@(posedge CLK) begin
	if(StallD == 0)
		InstrD <= Instr;
	if(FlushD)
		InstrD <= 0;
	end
	
endmodule
