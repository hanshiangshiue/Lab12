`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:05:49 09/16/2015 
// Design Name: 
// Module Name:    month_date 
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
module month_date(
    clk_i,
	 rst_n,
	 en,
	 leap_en,
	 month1,
	 month0,
	 day1,
	 day0
	 );
	 
input clk_i;
input rst_n;
input en;
input [1:0] leap_en;
output [3:0] month1;
output [3:0] month0;
output [3:0] day1;
output [3:0] day0;

reg [3:0] month1;
reg [3:0] month0;
reg [3:0] day1;
reg [3:0] day0;

reg [3:0] month1_tmp;
reg [3:0] month0_tmp;
reg [3:0] day1_tmp;
reg [3:0] day0_tmp;



always@(*)
begin
	if(en==1'b1)
	begin
		if(month1==4'd0 && month0==4'd2 && day1==4'd2 && day0==4'd8)
		begin
			case(leap_en)
			2'b00://leap year
			begin
				month1_tmp=month1;
				month0_tmp=month0;
				day1_tmp=day1;
				day0_tmp=4'd9;
			end
			default://not leap
			begin
				month1_tmp=4'd0;
				month0_tmp=4'd3;
				day1_tmp=4'd0;
				day0_tmp=4'd1;
			end
			endcase
		end
		else if(month1==4'd0 && month0==4'd2 && day1=='d2 && day0==4'd9)
		begin
			month1_tmp=4'd0;
			month0_tmp=4'd3;
			day1_tmp=4'd0;
			day0_tmp=4'd1;
		end
		else if(((month1==4'd0 && (month0==4'd1 || month0==4'd3 || month0==4'd5 || month0==4'd7 || month0==4'd8)) ||
					(month1==4'd1 && month0==4'd0)) && day1==4'd3 && day0==4'd1)//1,3,5,7,8,10
		begin
			month1_tmp=month1;
			month0_tmp=month0+4'd1;
			day1_tmp=4'd0;
			day0_tmp=4'd1;
		end
		else if(((month1==4'd0 && (month0==4'd4 || month0==4'd6)) || (month1==4'd1 && month0==4'd1)) && day1==4'd3 && day0==4'd0)//4,6,11
		begin
			month1_tmp=month1;
			month0_tmp=month0+4'd1;
			day1_tmp=4'd0;
			day0_tmp=4'd1;
		end
		else if(month1==4'd0 && month0==4'd9 && day1==4'd3 && day0==4'd0)//9
		begin
			month1_tmp=month1+4'd1;
			month0_tmp=4'd0;
			day1_tmp=4'd0;
			day0_tmp=4'd1;
		end
		else if(month1==4'd1 && month0==4'd2 && day1==4'd3 && day0==4'd1)//12
		begin
			month1_tmp=4'd0;
			month0_tmp=4'd1;
			day1_tmp=4'd0;
			day0_tmp=4'd1;
		end
		else if(day0==4'd9)
		begin
			month1_tmp=month1;
			month0_tmp=month0;
			day1_tmp=day1+4'd1;
			day0_tmp=4'd0;
		end
		else
		begin
			month1_tmp=month1;
			month0_tmp=month0;
			day1_tmp=day1;
			day0_tmp=day0+4'd1;
		end
	end
	else//en==1'b0
	begin
		month1_tmp=month1;
		month0_tmp=month0;
		day1_tmp=day1;
		day0_tmp=day0;
	end
end



always@(posedge clk_i or negedge rst_n)
begin
	if(~rst_n)
	begin
		month1<=4'd0;
		month0<=4'd1;
		day1<=4'd0;
		day0<=4'd1;
	end
	else
	begin
		month1<=month1_tmp;
		month0<=month0_tmp;
		day1<=day1_tmp;
		day0<=day0_tmp;
	end
end

endmodule
