////////////////////////////////////////////////////////////////////////
// Department of Computer Science
// National Tsing Hua University
// Project   : Design Gadgets for Hardware Lab
// Module    : RAM_ctrl
// Author    : Chih-Tsun Huang
// E-mail    : cthuang@cs.nthu.edu.tw
// Revision  : 2
// Date      : 2011/04/13
module RAM_ctrl (
    clk_div,
	 rst_n,
	 change,
	 en,
	 ap,
	 m,
	 hour1_12,
	 hour0_12,
	 hour1_24,
	 hour0_24,
	 day1,
	 day0,
	 month1,
	 month0,
	 year2,
	 year1,
	 year0,
	 data_out,
	 data_valid
	 );

input clk_div;
input rst_n;
input change;
input en;
input [3:0] ap;
input [3:0] m;
input [3:0] hour1_12;
input [3:0] hour0_12;
input [3:0] hour1_24;
input [3:0] hour0_24;
input [3:0] day1;
input [3:0] day0;
input [3:0] month1;
input [3:0] month0;
input [3:0] year2;
input [3:0] year1;
input [3:0] year0;
output [7:0] data_out;
output data_valid;

reg [7:0] data_out;
reg data_valid;

//1 frame=8*(64*8) bits -> 1 frame divided into 16 parts, every part has 256 bits 
  parameter markX  = 256'hc003_e007_700e_381c_1c38_0e70_07e0_03c0_03c0_07e0_0e70_1c38_381c_700e_e007_c003;
  parameter mark0  = 256'h0000_07e0_0ff0_300c_6006_6006_6006_6006_6006_6006_6006_6006_300c_0ff0_07e0_0000;
  parameter mark1  = 256'h0000_0780_0f80_3980_0180_0180_0180_0180_0180_0180_0180_0180_0180_3ffc_3ffc_0000;
  parameter mark2  = 256'h0000_07c0_0ff0_381c_700e_000e_000e_001c_0070_01c0_0700_1c00_7000_7ffe_7ffe_0000;
  parameter mark3  = 256'h0000_1ff8_3ffc_600e_0006_0006_000e_1ffc_1ffc_000e_0006_0006_600e_3ffc_1ff8_0000;
  parameter mark4  = 256'h0000_007c_003c_00cc_018c_030c_060c_0c0c_180c_300c_7fff_7fff_000c_000c_000c_0000;
  parameter mark5  = 256'h0000_3ffc_3ffc_3000_3000_3000_3fe0_3ff0_0038_001c_000c_001c_0038_3ff0_3fe0_0000;
  parameter mark6  = 256'h0000_03e0_07c0_0600_0c00_1800_3000_7ff0_7ff8_6018_600c_300c_1818_0c30_07e0_0000;
  parameter mark7  = 256'h0000_3ffc_3ffc_300c_300c_0018_0018_0030_0030_0060_0060_00c0_00c0_0180_0300_0000;
  parameter mark8  = 256'h0000_1ff8_3ffc_700e_6006_6006_700e_3ffc_3ffc_700e_6006_6006_700e_3ffc_1ff8_0000;
  parameter mark9  = 256'h0000_1ff8_3ffc_700e_6006_6006_700e_3ffe_3ffe_0006_000c_0018_0030_0fe0_1fc0_0000;
  parameter markA  = 256'h0180_0180_0240_0240_0420_0420_0810_0FF0_1FF8_1008_2004_2004_4002_4002_8001_8001;
  parameter markP  = 256'h3FFC_2004_2004_2004_2004_2004_2004_3FFC_2000_2000_2000_2000_2000_2000_2000_2000;
  parameter markM  = 256'h8001_C003_A005_9009_8811_8421_8241_8181_8001_8001_8001_8001_8001_8001_8001_8001;
  parameter IDLE  = 2'd0;
  parameter WRITE = 2'd1;
  parameter GETDATA = 2'd2;
  parameter TRANSDATA = 2'd3;

  reg [5:0] addr, addr_next;
  reg [5:0] counter_word, counter_word_next;
  wire [63:0] data_out_64;
  reg [63:0] data_in;
  reg [15:0] in_temp0, in_temp1, in_temp2, in_temp3;
  reg [1:0] cnt, cnt_next;  //count mark row
  reg [511:0] mem, mem_next;
  reg [1:0] state, state_next;
  reg flag, flag_next;
  reg [7:0] data_out_next;
  reg data_valid_next;
  reg wen, wen_next;
  reg temp_change, temp_change_next;
  
  reg [3:0]col1,col2,col3,col4;//column
 
  always@*
	begin
		case(cnt)
			2'b00://ampm
				begin
				col1=ap;
				col2=m;
				col3=hour1_12;
				col4=hour0_12;
				end
			2'b01://24hr
				begin
				col1=4'd0;
				col2=4'd0;
				col3=hour1_24;
				col4=hour0_24;
				end
			2'b10://month date
				begin
				col1=month1;
				col2=month0;
				col3=day1;
				col4=day0;
				end
			2'b11://year
				begin
				col1=4'd2;
				col2=year2;
				col3=year1;
				col4=year0;
				end
		endcase
		
		case(col1)
			4'd0:		in_temp0 = mark0[(240-((addr%16)*16))+:16];
			4'd1:		in_temp0 = mark1[(240-((addr%16)*16))+:16];
			4'd2:		in_temp0 = mark2[(240-((addr%16)*16))+:16];
			4'd3:		in_temp0 = mark3[(240-((addr%16)*16))+:16];
			4'd4:		in_temp0 = mark4[(240-((addr%16)*16))+:16];
			4'd5:		in_temp0 = mark5[(240-((addr%16)*16))+:16];
			4'd6:		in_temp0 = mark6[(240-((addr%16)*16))+:16];
			4'd7:		in_temp0 = mark7[(240-((addr%16)*16))+:16];
			4'd8:		in_temp0 = mark8[(240-((addr%16)*16))+:16];
			4'd9:		in_temp0 = mark9[(240-((addr%16)*16))+:16];
			4'd10:	in_temp0 = markA[(240-((addr%16)*16))+:16];
			4'd11:	in_temp0 = markP[(240-((addr%16)*16))+:16];
			default:	in_temp0 = markX[(240-((addr%16)*16))+:16];
		endcase
		
		case(col2)
			4'd0:		in_temp1 = mark0[(240-((addr%16)*16))+:16];
			4'd1:		in_temp1 = mark1[(240-((addr%16)*16))+:16];
			4'd2:		in_temp1 = mark2[(240-((addr%16)*16))+:16];
			4'd3:		in_temp1 = mark3[(240-((addr%16)*16))+:16];
			4'd4:		in_temp1 = mark4[(240-((addr%16)*16))+:16];
			4'd5:		in_temp1 = mark5[(240-((addr%16)*16))+:16];
			4'd6:		in_temp1 = mark6[(240-((addr%16)*16))+:16];
			4'd7:		in_temp1 = mark7[(240-((addr%16)*16))+:16];
			4'd8:		in_temp1 = mark8[(240-((addr%16)*16))+:16];
			4'd9:		in_temp1 = mark9[(240-((addr%16)*16))+:16];
			4'd12:	in_temp1 = markM[(240-((addr%16)*16))+:16];
			default:	in_temp1 = markX[(240-((addr%16)*16))+:16];
		endcase
		
		case(col3)
			4'd0:		in_temp2 = mark0[(240-((addr%16)*16))+:16];
			4'd1:		in_temp2 = mark1[(240-((addr%16)*16))+:16];
			4'd2:		in_temp2 = mark2[(240-((addr%16)*16))+:16];
			4'd3:		in_temp2 = mark3[(240-((addr%16)*16))+:16];
			4'd4:		in_temp2 = mark4[(240-((addr%16)*16))+:16];
			4'd5:		in_temp2 = mark5[(240-((addr%16)*16))+:16];
			4'd6:		in_temp2 = mark6[(240-((addr%16)*16))+:16];
			4'd7:		in_temp2 = mark7[(240-((addr%16)*16))+:16];
			4'd8:		in_temp2 = mark8[(240-((addr%16)*16))+:16];
			4'd9:		in_temp2 = mark9[(240-((addr%16)*16))+:16];
			default:	in_temp2 = markX[(240-((addr%16)*16))+:16];
		endcase
			
		case(col4)
			4'd0:		in_temp3 = mark0[(240-((addr%16)*16))+:16];
			4'd1:		in_temp3 = mark1[(240-((addr%16)*16))+:16];
			4'd2:		in_temp3 = mark2[(240-((addr%16)*16))+:16];
			4'd3:		in_temp3 = mark3[(240-((addr%16)*16))+:16];
			4'd4:		in_temp3 = mark4[(240-((addr%16)*16))+:16];
			4'd5:		in_temp3 = mark5[(240-((addr%16)*16))+:16];
			4'd6:		in_temp3 = mark6[(240-((addr%16)*16))+:16];
			4'd7:		in_temp3 = mark7[(240-((addr%16)*16))+:16];
			4'd8:		in_temp3 = mark8[(240-((addr%16)*16))+:16];
			4'd9:		in_temp3 = mark9[(240-((addr%16)*16))+:16];
			default:	in_temp3 = markX[(240-((addr%16)*16))+:16];
		endcase
	end
  


  RAM R1(
    .clka(clk_div),
    .wea(wen),
    .addra(addr),
    .dina(data_in),
    .douta(data_out_64)
  );

  always @(posedge clk_div or negedge rst_n) begin
    if (!rst_n) begin
      addr = 6'd0;
      cnt = 2'd0;
      mem = 512'd0;
      state = IDLE;
      flag = 1'b0;
      counter_word = 6'd0;
      data_out = 8'd0;
      data_valid = 1'd0;
      wen = 1'b1;
      temp_change = 1'b0;
    end else begin
      addr = addr_next;
      cnt = cnt_next;
      mem = mem_next;
      state = state_next;
      flag = flag_next;
      counter_word = counter_word_next;
      data_out = data_out_next;
      data_valid = data_valid_next;
      wen = wen_next;
      temp_change = temp_change_next;
    end
  end

  always @(*) begin
    state_next = state;
    case(state)
      IDLE: begin
        if (wen) begin
          state_next = WRITE;
        end else begin
          state_next = GETDATA;
        end
      end
      WRITE: begin
        if (addr == 6'd63) begin
          state_next = GETDATA;
        end
      end
      GETDATA: begin
        if (flag == 1'b1) begin
          state_next = TRANSDATA;
        end
      end
      TRANSDATA: begin
        if (addr == 6'd0 && counter_word == 6'd63 && en) begin
          state_next = IDLE;
        end else if (counter_word == 6'd63 && en) begin
          state_next = GETDATA;
        end
      end
    endcase
  end

  always @(*) begin
    addr_next = addr;
    data_in = 64'd0;
    cnt_next = cnt;
    mem_next = mem;
    flag_next = 1'b0;
    counter_word_next = counter_word;
    data_valid_next = 1'd0;
    data_out_next = 8'd0;
    case(state)
      WRITE: begin
        addr_next = addr + 1'b1;
        data_in = {in_temp0, in_temp1, in_temp2, in_temp3};	
        if (addr == 6'd15 || addr == 6'd31 || addr == 6'd47 || addr == 6'd63) begin
          cnt_next = cnt + 1'd1;		
        end
      end
      GETDATA: begin
        if (!flag) begin
          addr_next = addr + 1'b1;
        end
        if ((addr%8) == 6'd7) begin
          flag_next = 1'b1;
        end
        if ((addr%8) >= 6'd1 || flag) begin
          mem_next[(((addr-1)%8)*64)+:64] = data_out_64;
        end
      end
      TRANSDATA: begin
        if (en) begin
          counter_word_next = counter_word + 1'b1;
          data_valid_next = 1'b1;
          data_out_next = {mem[511 - counter_word],
            mem[447 - counter_word],
            mem[383 - counter_word],
            mem[319 - counter_word],
            mem[255 - counter_word],
            mem[191 - counter_word],
            mem[127 - counter_word],
            mem[63 - counter_word]};
        end
      end
    endcase
  end
 
  //wen control
  always @(*) begin
    wen_next = wen;
    temp_change_next = temp_change;
    if (change) begin
      temp_change_next = 1'b1;
    end
    if (state == WRITE && addr == 6'd63) begin
      wen_next = 1'b0;
    end
    if (state == TRANSDATA && addr == 6'd0 && counter_word == 6'd63 && temp_change == 1'b1) begin
      temp_change_next = 1'b0;
      wen_next = 1'b1;
    end
  end
endmodule
