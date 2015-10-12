`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:55:03 09/02/2015 
// Design Name: 
// Module Name:    min0 
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
module min0(
    clk_out,
	 rst_n,
	 decrease,//要不要-1
	 increase,//碼表要不要+1
	 increase_set,//setting要不要+1
	 value,
	 over,//碼表+算完了沒 準備進位
	 over_set,//setting時+算完了沒 準備進位
	 borrow//-算完了沒 準備跟min1借
	 );

input clk_out;
input rst_n;
input decrease;
input increase;
input increase_set;
output [3:0] value;
output over;
output over_set;
output borrow;


reg [3:0] value;
reg [3:0] value_tmp;
reg over;
reg over_set;
reg borrow;


always@(*)
begin
	if(value==4'd0 && decrease==1'b1)
	begin
		value_tmp=4'd9;
		over=1'b0;
		over_set=1'b0;
		borrow=1'b1;
	end
	else if(value!=4'd0 && decrease==1'b1)
	begin
		value_tmp=value-4'd1;
		over=1'b0;
		over_set=1'b0;
		borrow=1'b0;
	end
	else if(value==4'd9 && increase==1'b1)
	begin
		value_tmp=4'd0;
		over=1'b1;
		over_set=1'b0;
		borrow=1'b0;
	end
	else if(value!=4'd9 && increase==1'b1)
	begin
		value_tmp=value+4'd1;
		over=1'b0;
		over_set=1'b0;
		borrow=1'b0;
	end
	else if(value==4'd9 && increase_set==1'b1)
	begin
		value_tmp=4'd0;
		over=1'b0;
		over_set=1'b1;
		borrow=1'b0;
	end
	else if(value!=4'd9 && increase_set==1'b1)
	begin
		value_tmp=value+4'd1;
		over=1'b0;
		over_set=1'b0;
		borrow=1'b0;
	end
	else
	begin
		value_tmp=value;
		over=1'b0;
		over_set=1'b0;
		borrow=1'b0;
	end
end




always@(posedge clk_out or negedge rst_n)
begin
	if(~rst_n)
	begin
		value<=4'd0;
	end
	else
		value<=value_tmp;
end



endmodule
