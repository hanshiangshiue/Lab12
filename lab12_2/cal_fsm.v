`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:23:52 09/04/2015 
// Design Name: 
// Module Name:    cal_fsm 
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
module cal_fsm(
    clk,
	 rst_n,
	 in1,//button1 for start/stop
	 in2,//button2 for lap
	 mode,//絏or计璸竟
	 set,//setting
	 state,
	 watch_enable,//絏秨﹍璸计
	 countdown_enable,//计璸竟秨﹍计
	 freeze,
	 sethr_enable,
	 setmin_enable
	 );

input clk;
input rst_n;
input in1;
input in2;
input mode;
input set;
output [2:0] state;
output watch_enable;
output countdown_enable;
output freeze;
output sethr_enable;
output setmin_enable;


reg [2:0] state; 
reg [2:0] next_state;
reg watch_enable;
reg countdown_enable;
reg freeze;
reg sethr_enable;
reg setmin_enable;

always@(*)
begin
	if(~mode)//絏
	begin
		case(state)
		3'b000://stop
		begin
			if(in1)
			begin
				next_state=3'b001;//start
				watch_enable=1'b1;
				countdown_enable=1'b0;
				freeze=1'b0;
				sethr_enable=1'b0;
				setmin_enable=1'b0;
			end
			else
			begin
				next_state=3'b000;
				watch_enable=1'b0;
				countdown_enable=1'b0;
				freeze=1'b0;
				sethr_enable=1'b0;
				setmin_enable=1'b0;
			end
		end
		3'b001://start
		begin
			if(in1)
			begin
				next_state=3'b000;
				watch_enable=1'b0;
				countdown_enable=1'b0;
				freeze=1'b0;
				sethr_enable=1'b0;
				setmin_enable=1'b0;
			end
			else if(in2)
			begin
				next_state=3'b010;//lap
				watch_enable=1'b1;
				countdown_enable=1'b0;
				freeze=1'b1;
				sethr_enable=1'b0;
				setmin_enable=1'b0;
			end
			else
			begin
				next_state=3'b001;
				watch_enable=1'b1;
				countdown_enable=1'b0;
				freeze=1'b0;
				sethr_enable=1'b0;
				setmin_enable=1'b0;
			end
		end
		3'b010://lap
		begin
			if(in2)
			begin
				next_state=3'b001;
				watch_enable=1'b1;
				countdown_enable=1'b0;
				freeze=1'b0;
				sethr_enable=1'b0;
				setmin_enable=1'b0;
			end
			else
			begin
				next_state=3'b010;
				watch_enable=1'b1;
				countdown_enable=1'b0;
				freeze=1'b1;
				sethr_enable=1'b0;
				setmin_enable=1'b0;
			end
		end
		default:
		begin
			next_state=3'b000;
			watch_enable=1'b0;
			countdown_enable=1'b0;
			freeze=1'b0;
			sethr_enable=1'b0;
			setmin_enable=1'b0;
		end
		endcase
	end
	else//计璸竟
	begin
		if(~set)
		begin
			case(state)
			3'b000://stop
			begin
				if(in1)
				begin
					next_state=3'b101;//start
					watch_enable=1'b0;
					countdown_enable=1'b1;
					freeze=1'b0;
					sethr_enable=1'b0;
					setmin_enable=1'b0;
				end
				else
				begin
					next_state=3'b000;
					watch_enable=1'b0;
					countdown_enable=1'b0;
					freeze=1'b0;
					sethr_enable=1'b0;
					setmin_enable=1'b0;
				end
			end
			3'b101:
			begin
				if(in1)
				begin
					next_state=3'b000;
					watch_enable=1'b0;
					countdown_enable=1'b0;
					freeze=1'b0;
					sethr_enable=1'b0;
					setmin_enable=1'b0;
				end
				else if(in2)
				begin
					next_state=3'b110;//lap
					watch_enable=1'b0;
					countdown_enable=1'b1;
					freeze=1'b1;
					sethr_enable=1'b0;
					setmin_enable=1'b0;
				end
				else
				begin
					next_state=3'b101;
					watch_enable=1'b0;
					countdown_enable=1'b1;
					freeze=1'b0;
					sethr_enable=1'b0;
					setmin_enable=1'b0;
				end
			end
			3'b110://lap
			begin
				if(in2)
				begin
					next_state=3'b101;
					watch_enable=1'b0;
					countdown_enable=1'b1;
					freeze=1'b0;
					sethr_enable=1'b0;
					setmin_enable=1'b0;
				end
				else
				begin
					next_state=3'b110;
					watch_enable=1'b0;
					countdown_enable=1'b1;
					freeze=1'b1;
					sethr_enable=1'b0;
					setmin_enable=1'b0;
				end
			end
			default:
			begin
				next_state=3'b000;
				watch_enable=1'b0;
				countdown_enable=1'b0;
				freeze=1'b0;
				sethr_enable=1'b0;
				setmin_enable=1'b0;
			end
			endcase
		end
		else//setting
		begin
			case(state)
			3'b000://setting
			begin
				if(in1)
				begin
					next_state=3'b100;//set hour
					watch_enable=1'b0;
					countdown_enable=1'b0;
					freeze=1'b0;
					sethr_enable=1'b1;
					setmin_enable=1'b0;
				end
				else if(in2)
				begin
					next_state=3'b011;//set min
					watch_enable=1'b0;
					countdown_enable=1'b0;
					freeze=1'b0;
					sethr_enable=1'b0;
					setmin_enable=1'b1;
				end
				else
				begin
					next_state=3'b000;
					watch_enable=1'b0;
					countdown_enable=1'b0;
					freeze=1'b0;
					sethr_enable=1'b0;
					setmin_enable=1'b0;
				end
			end
			3'b100://set hour
			begin
				if(in1)
				begin
					next_state=3'b000;
					watch_enable=1'b0;
					countdown_enable=1'b0;
					freeze=1'b0;
					sethr_enable=1'b0;
					setmin_enable=1'b0;
				end
				else
				begin
					next_state=3'b100;
					watch_enable=1'b0;
					countdown_enable=1'b0;
					freeze=1'b0;
					sethr_enable=1'b1;
					setmin_enable=1'b0;
				end
			end
			3'b011://set min
			begin
				if(in2)
				begin
					next_state=3'b000;
					watch_enable=1'b0;
					countdown_enable=1'b0;
					freeze=1'b0;
					sethr_enable=1'b0;
					setmin_enable=1'b0;
				end
				else
				begin
					next_state=3'b011;//set min
					watch_enable=1'b0;
					countdown_enable=1'b0;
					freeze=1'b0;
					sethr_enable=1'b0;
					setmin_enable=1'b1;
				end
			end
			default:
			begin
				next_state=3'b000;
				watch_enable=1'b0;
				countdown_enable=1'b0;
				freeze=1'b0;
				sethr_enable=1'b0;
				setmin_enable=1'b0;
			end
			endcase
		end
	end
end




always@(posedge clk or negedge rst_n)
begin
	if(~rst_n)
		state<=3'b000;
	else
		state<=next_state;
end





endmodule
