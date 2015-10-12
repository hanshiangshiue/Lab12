`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:26:17 09/17/2015 
// Design Name: 
// Module Name:    integrate 
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
module integrate(
	 clk,
	 rst_n,
	 button,
	 time_or_watch,
	 mode,
	 set,
	 show,
	 button1,
	 button2,
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
input time_or_watch;//display time(0) or down-counter(1) on LCD
input mode;//display down-counter(0) or up-counter(1) on LCD
input set;//down-counter setting
input show;//in up-counter choose to display (hour:min)(0) or (--:second)(1) on LCD
input button1;//for start/stop or set hour
input button2;//for lap or set minute
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
wire clk_150;
wire clk_fast;
wire day_en;
wire [1:0] leap_en;
wire pb_debounced1;
wire pb_debounced2;
wire out_pulse1;
wire out_pulse2;
wire [2:0] state;
wire watch_en;
wire cdown_en;
wire freeze;
wire sethr_en;
wire setmin_en;
reg [3:0] in0;
reg [3:0] in1;
reg [3:0] in2;
reg [3:0] in3;
reg [3:0] sec0_tmp;
reg [3:0] sec1_tmp;
reg [3:0] min0_tmp;
reg [3:0] min1_tmp;
reg [3:0] hour0_tmp;
reg [3:0] hour1_tmp;
wire [3:0] second0;
wire [3:0] second1;
wire [3:0] minute0;
wire [3:0] minute1;
wire [3:0] hour0;
wire [3:0] hour1;
wire sec1de;
wire sec1inw;
wire min0de;
wire min0inw;
wire min1inw;
wire min1ins;
wire min1de;
wire hr0de;
wire re;
wire hr1ins;
wire hr1de;



////////////////////time display//////////////////////////
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
	 .time_or_watch(time_or_watch),
	 .mode(mode),
	 .show(show),
	 .in0(in0),
	 .in1(in1),
	 .in2(in2),
	 .in3(in3),
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
	 .clk_150(clk_150),
	 .clk_fast(clk_fast)
    );


always@(*)
begin
	if(~button[2])
		clk_i=clk_fast;
	else if(~button[1])
		clk_i=clk_150;
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





/////////////////////stop watch//////////////////////

debounce deb1(
	.clk_150(clk_150),
	.pb_in(button1),
	.pb_debounced(pb_debounced1)
	);


debounce deb2(
	.clk_150(clk_150),
	.pb_in(button2),
	.pb_debounced(pb_debounced2)
	);


one_pulse o1(
    .clk(clk),
	 .rst_n(rst_n),
	 .in_trig(pb_debounced1),
	 .out_pulse(out_pulse1)
	 );

one_pulse o2(
    .clk(clk),
	 .rst_n(rst_n),
	 .in_trig(pb_debounced2),
	 .out_pulse(out_pulse2)
	 );


cal_fsm cfsm(
    .clk(clk),
	 .rst_n(rst_n),
	 .in1(out_pulse1),//button1 for start/stop
	 .in2(out_pulse2),//button2 for lap
	 .mode(mode),//碼表or倒數計時器
	 .set(set),//setting
	 .state(state),
	 .watch_enable(watch_en),//碼表開始計數
	 .countdown_enable(cdown_en),//倒數計時器開始倒數
	 .freeze(freeze),
	 .sethr_enable(sethr_en),
	 .setmin_enable(setmin_en)
	 );




always@(*)//lap
begin
	if(freeze==1'b0)
	begin
		sec0_tmp=second0;
		sec1_tmp=second1;
		min0_tmp=minute0;
		min1_tmp=minute1;
		hour0_tmp=hour0;
		hour1_tmp=hour1;
	end
	else//freeze==1'b1
	begin
		sec0_tmp=sec0_tmp;
		sec1_tmp=sec1_tmp;
		min0_tmp=min0_tmp;
		min1_tmp=min1_tmp;
		hour0_tmp=hour0_tmp;
		hour1_tmp=hour1_tmp;
	end
end




always@(*)//14 segment displays
begin
	if(mode==1'b1)//倒數計時器
	begin
		if(show==1'b0)//顯示小時:分
		begin
			if(state==3'b110)
			begin
				in0=hour1_tmp;
				in1=hour0_tmp;
				in2=min1_tmp;
				in3=min0_tmp;
			end
			else
			begin
				in0=hour1;
				in1=hour0;
				in2=minute1;
				in3=minute0;
			end
		end
		else//show==1'b1 顯示--:秒
		begin
			if(state==3'b110)
			begin
				in0=4'd15;
				in1=4'd15;
				in2=sec1_tmp;
				in3=sec0_tmp;
			end
			else
			begin
				in0=4'd15;
				in1=4'd15;
				in2=second1;
				in3=second0;
			end
		end
	end
	else//碼表
	begin
		if(state==3'b010)
		begin
			in0=min1_tmp;
			in1=min0_tmp;
			in2=sec1_tmp;
			in3=sec0_tmp;
		end
		else
		begin
			in0=minute1;
			in1=minute0;
			in2=second1;
			in3=second0;
		end
	end
		
end



sec0 u_sec0(
	 .clk_out(clk_out),
	 .rst_n(rst_n),
	 .decrease(cdown_en),//倒數計時器要不要-1
	 .increase(watch_en),//碼表要不要+1
	 .second1(second1),
	 .minute0(minute0),
	 .minute1(minute1),
	 .hour0(hour0),
	 .hour1(hour1),
	 .value(second0),
	 .borrow(sec1de),//-算完了沒,準備跟sec1借
	 .over(sec1inw)//碼表+算完了沒,準備進位
	 );


sec1 u_sec1(
    .clk_out(clk_out),
	 .rst_n(rst_n),
	 .decrease(sec1de),//倒數計時器要不要-1
	 .increase(sec1inw),//碼表要不要+1
	 .value(second1),
	 .borrow(min0de),//-算完了沒,準備跟min0借
	 .over(min0inw)//碼表+算完了沒,準備進位
	 );



min0 u_min0(
    .clk_out(clk_out),
	 .rst_n(rst_n),
	 .decrease(min0de),//要不要-1
	 .increase(min0inw),//碼表要不要+1
	 .increase_set(setmin_en),//setting要不要+1
	 .value(minute0),
	 .over(min1inw),//碼表+算完了沒 準備進位
	 .over_set(min1ins),//setting時+算完了沒 準備進位
	 .borrow(min1de)//-算完了沒 準備跟min1借
	 );



min1 u_min1(
    .clk_out(clk_out),
	 .rst_n(rst_n),
	 .decrease(min1de),
	 .increase(min1inw),
	 .increase_set(min1ins),
	 .value(minute1),
	 .borrow(hr0de)
	 );



hour0 u_hour0(
    .clk_out(clk_out),
	 .rst_n(rst_n),
	 .decrease(hr0de),
	 .increase_set(sethr_en),
	 .re(re),
	 .value(hour0),
	 .over_set(hr1ins),
	 .borrow(hr1de)
	 );



hour1 u_hour1(
    .clk_out(clk_out),
	 .rst_n(rst_n),
	 .decrease(hr1de),
	 .increase_set(hr1ins),
	 .value(hour1),
	 .re(re)
	 );


endmodule
