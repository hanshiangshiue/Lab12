`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:45:13 09/02/2015 
// Design Name: 
// Module Name:    sec0 
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
module sec0(
	 clk_out,
	 rst_n,
	 decrease,//倒數計時器要不要-1
	 increase,//碼表要不要+1
	 second1,
	 minute0,
	 minute1,
	 hour0,
	 hour1,
	 value,
	 borrow,//-算完了沒,準備跟sec1借
	 over,//碼表+算完了沒,準備進位
	 LED
	 );

input clk_out;
input rst_n;
input decrease;
input increase;
input [3:0] second1;
input [3:0] minute0;
input [3:0] minute1;
input [3:0] hour0;
input [3:0] hour1;
output [3:0] value;
output borrow;
output over;
output [15:0] LED;

reg borrow;
reg over;
reg [15:0] LED;
reg [3:0] value;
reg [3:0] value_tmp;
reg unable;//全部倒數完了沒




always@(*)
begin
	if(hour1==4'd0 && hour0==4'd0 && minute0==4'd0 && minute1==4'd0 && second1==4'd0)
	begin
		unable=1'b1;
	end
	else
	begin
		unable=1'b0;
	end
end






always@(*)
begin
	if(value==4'd0 && decrease==1'b1 && unable==1'b1)
	begin
		value_tmp=4'd0;
		borrow=1'b0;
		over=1'b0;
		LED=16'b1111_1111_1111_1111;
	end
	else if(value==4'd0 && decrease==1'b1)
	begin
		value_tmp=4'd9;
		borrow=1'b1;
		over=1'b0;
		LED=16'b0000_0000_0000_0000;
	end
	else if(value!=4'd0 && decrease==1'b1)
	begin
		value_tmp=value-4'd1;
		borrow=1'b0;
		over=1'b0;
		LED=16'b0000_0000_0000_0000;
	end
	else if(value==4'd9 && increase==1'b1)
	begin
		value_tmp=4'd0;
		borrow=1'b0;
		over=1'b1;
		LED=16'b0000_0000_0000_0000;
	end
	else if(value!=4'd9 && increase==1'b1)
	begin
		value_tmp=value+4'd1;
		borrow=1'b0;
		over=1'b0;
		LED=16'b0000_0000_0000_0000;
	end
	else
	begin
		value_tmp=value;
		borrow=1'b0;
		over=1'b0;
		LED=16'b0000_0000_0000_0000;
	end
end



always@(posedge clk_out or negedge rst_n)
begin
	if(~rst_n)
		value<=4'd0;
	else
		value<=value_tmp;
end



endmodule
