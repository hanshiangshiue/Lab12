`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:48:07 09/03/2015 
// Design Name: 
// Module Name:    hour0 
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
module hour0(
    clk_out,
	 rst_n,
	 decrease,
	 increase_set,
	 re,
	 value,
	 over_set,
	 borrow
	 );


input clk_out;
input rst_n;
input decrease;
input increase_set;
input re;
output [3:0] value;
output over_set;
output borrow;


reg [3:0] value;
reg [3:0] value_tmp;
reg over_set;
reg borrow;



always@(*)
begin
	if(value==4'd0 && decrease==1'b1)
	begin
		value_tmp=4'd9;
		borrow=1'b1;
		over_set=1'b0;
	end
	else if(value!=4'd0 && decrease==1'b1)
	begin
		value_tmp=value-4'd1;
		borrow=1'b0;
		over_set=1'b0;
	end
	else if(value==4'd3 && increase_set==1'b1 && re==1'b1)
	begin
		value_tmp=4'd0;
		borrow=1'b0;
		over_set=1'b1;
	end
	else if(value==4'd9 && increase_set==1'b1)
	begin
		value_tmp=4'd0;
		borrow=1'b0;
		over_set=1'b1;
	end
	else if(value!=4'd9 && increase_set==1'b1)
	begin
		value_tmp=value+4'd1;
		borrow=1'b0;
		over_set=1'b0;
	end
	else
	begin
		value_tmp=value;
		borrow=1'b0;
		over_set=1'b0;
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
