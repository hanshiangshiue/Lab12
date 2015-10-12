`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:37:24 09/17/2015 
// Design Name: 
// Module Name:    time_display 
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
module time_display(
    clk,
	 rst_n,
	 button,
	 LCD_rst,
	 LCD_cs,
	 LCD_rw,
	 LCD_di,
	 LCD_data,
	 LCD_en
	 );
input clk;
input rst_n;
input [2:0] button;//control different clock
output LCD_rst;
output [1:0] LCD_cs;
output LCD_rw;
output LCD_di;
output [7:0] LCD_data;
output LCD_en;

wire [1:0] LCD_cs;
wire [7:0] LCD_data;


reg year_en;
reg clk_i;

wire clk_div;
wire [3:0] ampm;
wire en;
wire [3:0] hour1_12;
wire [3:0] hour0_12;
wire [3:0] hour1_24;
wire [3:0] hour0_24;
wire [3:0] day1;
wire [3:0] day0;
wire [3:0] month1;
wire [3:0] month0;
wire [3:0] year2;
wire [3:0] year1;
wire [3:0] year0;
wire out_valid;
wire [7:0] data_out;
wire clk_out;
wire clk_slow;
wire clk_medium;
wire clk_fast;
wire day_en;
wire [1:0] leap_en;




  clock_divider #(
    .half_cycle(200),         // half cycle = 200 (divided by 400)
    .counter_width(8)         // counter width = 8 bits
  ) clk100K (
    .rst_n(rst_n),
    .clk(clk),
    .clk_div(clk_div)
  );
  
  

RAM_ctrl R1(
    .clk_div(clk_div),
	 .rst_n(rst_n),
	 .change(1'b1),
	 .en(en),
	 .ap(ampm),
	 .m(4'd12),
	 .hour1_12(hour1_12),
	 .hour0_12(hour0_12),
	 .hour1_24(hour1_24),
	 .hour0_24(hour0_24),
	 .day1(day1),
	 .day0(day0),
	 .month1(month1),
	 .month0(month0),
	 .year2(year2),
	 .year1(year1),
	 .year0(year0),
	 .data_out(data_out),
	 .data_valid(out_valid)
	 );



  lcd_ctrl d1 (
    .clk(clk_div),
    .rst_n(rst_n),
    .data(data_out),           // memory value  
    .data_valid(out_valid),    // if data_valid = 1 the data is valid
    .LCD_di(LCD_di),
    .LCD_rw(LCD_rw),
    .LCD_en(LCD_en),
    .LCD_rst(LCD_rst),
    .LCD_cs(LCD_cs),
    .LCD_data(LCD_data),
    .en_tran(en)
  );





freq_div f1(
    .clk(clk),
    .rst_n(rst_n),
    .clk_out(clk_out),
	 .clk_slow(clk_slow),
	 .clk_medium(clk_medium),
	 .clk_fast(clk_fast)
    );


always@(*)
begin
	if(~button[2])
		clk_i=clk_fast;
	else if(~button[1])
		clk_i=clk_medium;
	else if(~button[0])
		clk_i=clk_slow;
	else
		clk_i=clk_out;
end



hour_24 hr24(
    .clk_i(clk_i),
	 .rst_n(rst_n),
	 .hour1(hour1_24),
	 .hour0(hour0_24),
	 .day_en(day_en)
	 );



hour_12 hr12(
    .clk_i(clk_i),
	 .rst_n(rst_n),
	 .hour1_12(hour1_12),
	 .hour0_12(hour0_12),
	 .ampm(ampm)
	 );



month_date m1(
    .clk_i(clk_i),
	 .rst_n(rst_n),
	 .en(day_en),
	 .leap_en(leap_en),
	 .month1(month1),
	 .month0(month0),
	 .day1(day1),
	 .day0(day0)
	 );



always@(*)
begin
	if(month1==4'd1 && month0==4'd2 && day1==4'd3 && day0==4'd1 && hour1_24==4'd0 && hour0_24==4'd0)
		year_en=1'b1;
	else
		year_en=1'b0;
end



year y1(
    .clk_i(clk_i),
	 .rst_n(rst_n),
	 .en(year_en),
	 .year2(year2),
	 .year1(year1),
	 .year0(year0),
	 .leap_en(leap_en)
	 );


endmodule
