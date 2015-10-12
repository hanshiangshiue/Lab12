`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:26:21 09/16/2015 
// Design Name: 
// Module Name:    hour_12 
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
module hour_12(
    clk_i,
	 rst_n,
	 hour1_12,
	 hour0_12,
	 ampm
	 );

input clk_i;
input rst_n;
output [3:0] hour1_12;
output [3:0] hour0_12;
output [3:0] ampm;

reg [3:0] hour1_12;
reg [3:0] hour0_12;
reg [3:0] ampm;

reg [3:0] hour1_12_tmp;
reg [3:0] hour0_12_tmp;
reg ampm_ctl;
reg ampm_ctl_tmp;


always@(hour1_12 or hour0_12)
begin
	if(hour1_12==4'd1 && hour0_12==4'd1)
	begin
		hour1_12_tmp=4'd1;
		hour0_12_tmp=4'd2;
		ampm_ctl_tmp=ampm_ctl+1'b1;
	end
	else if(hour1_12==4'd1 && hour0_12==4'd2)
	begin
		hour1_12_tmp=4'd0;
		hour0_12_tmp=4'd0;
		ampm_ctl_tmp=ampm_ctl;
	end
	else if(hour0_12==4'd9)
	begin
		hour1_12_tmp=hour1_12+4'd1;
		hour0_12_tmp=4'd0;
		ampm_ctl_tmp=ampm_ctl;
	end
	else
	begin
		hour1_12_tmp=hour1_12;
		hour0_12_tmp=hour0_12+4'd1;
		ampm_ctl_tmp=ampm_ctl;
	end
end


always@(ampm_ctl)
begin
	if(ampm_ctl==1'b0)
		ampm=4'd10;//A
	else
		ampm=4'd11;//P
end



always@(posedge clk_i or negedge rst_n)
begin
	if(~rst_n)
	begin
		hour1_12<=4'd0;
		hour0_12<=4'd0;
		ampm_ctl<=1'b0;//A
	end
	else
	begin
		hour1_12<=hour1_12_tmp;
		hour0_12<=hour0_12_tmp;
		ampm_ctl<=ampm_ctl_tmp;
	end
end



endmodule
