`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:30:56 09/16/2015 
// Design Name: 
// Module Name:    year 
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
module year(
    clk_i,
	 rst_n,
	 en,
	 year2,
	 year1,
	 year0,
	 leap_en
	 );

input clk_i;
input rst_n;
input en;
output [3:0] year2;
output [3:0] year1;
output [3:0] year0;
output [1:0] leap_en;

reg [3:0] year2;
reg [3:0] year1;
reg [3:0] year0;
reg [1:0] leap_en;

reg [3:0] year2_tmp;
reg [3:0] year1_tmp;
reg [3:0] year0_tmp;
reg [1:0] leap_en_tmp;


always@(*)
begin
	if(en==1'b1)
	begin
		if(year1==4'd9 && year0==4'd9)
		begin
			year2_tmp=year2+4'd1;
			year1_tmp=4'd0;
			year0_tmp=4'd0;
			leap_en_tmp=leap_en+2'b1;
		end
		else if(year0==4'd9)
		begin
			year2_tmp=year2;
			year1_tmp=year1+4'd1;
			year0_tmp=4'd0;
			leap_en_tmp=leap_en+2'b1;
		end
		else
		begin
			year2_tmp=year2;
			year1_tmp=year1;
			year0_tmp=year0+4'd1;
			leap_en_tmp=leap_en+2'b1;
		end
	end
	else//en==1'b0
	begin
		year2_tmp=year2;
		year1_tmp=year1;
		year0_tmp=year0;
		leap_en_tmp=leap_en;
	end
end



always@(posedge clk_i or negedge rst_n)
begin
	if(~rst_n)
	begin
		year2<=4'd0;
		year1<=4'd0;
		year0<=4'd0;
		leap_en<=2'b0;
	end
	else
	begin
		year2<=year2_tmp;
		year1<=year1_tmp;
		year0<=year0_tmp;
		leap_en<=leap_en_tmp;
	end
end

endmodule
