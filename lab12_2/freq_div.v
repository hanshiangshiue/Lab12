`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:23:46 03/27/2014 
// Design Name: 
// Module Name:    freq_div 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module freq_div(
    clk,
    rst_n,
    clk_out,
	 clk_slow,
	 clk_150,
	 clk_fast
    );


input clk;
input rst_n;
output clk_out;
output clk_slow;
output clk_150;
output clk_fast;
	
reg[24:0]cnt;
reg[24:0]cnt_tmp;
	
//assign ssd_ctl_en = cnt[17:16];
	
assign clk_out=cnt[24];
	
assign clk_slow=cnt[22];
	
assign clk_150=cnt[17];
	
assign clk_fast=cnt[15];
	

always@(cnt)
	cnt_tmp = cnt+1'b1;

	
always@(posedge clk or negedge rst_n)
	if(~rst_n)
		cnt<=25'd0;
	else
		cnt<=cnt_tmp;


endmodule
