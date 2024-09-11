`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/03 14:20:16
// Design Name: 
// Module Name: password_lock
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module password_lock(
    input [9:0]nums,
    input backspace,
    input reset,
    input clk_100Mhz,
    input confirm,
    input operate,
    input administrate,
    input relieve,
    output reg[6:0]segment_display,
    output reg[3:0]AN,
    output reg[14:0]led,
    output reg alarm
    );
    parameter size=4;
    reg [size-1:0]stable=1;//四种状态
    reg [9:0]key0=1,key1=1,key2=1,key3=1,nums0,nums1,nums2,nums3;
    reg confirm_record;
    reg [3:0]stable_record;
    reg [1:0]times=0;
    reg relieve_record;
    reg [12:0]counter;
    reg [8:0]counter0;
//分频
integer clk_cnt;
reg clk_400hz;
   always @(posedge clk_100Mhz)begin
        if(clk_cnt==30'd125000)
        begin clk_cnt <= 1'b0; clk_400hz <= ~clk_400hz;end
        else
        clk_cnt <= clk_cnt + 1'b1;
   end

 


wire [6:0]segment_display_connect0;
wire [3:0]AN_connect0;
wire [9:0]nums0_connect0,nums1_connect0,nums2_connect0,nums3_connect0;
digital_segment ins0(
.nums(nums),
.num0(0),.num1(0),.num2(0),.num3(0),
.backspace(backspace),
.reset(reset),
.reset_stable((stable==4'b0001)&&(stable_record!=4'b0001)),
.clk_400hz(clk_400hz),
.o_segment_display(segment_display_connect0),
.o_AN(AN_connect0),
.o_nums0(nums0_connect0),.o_nums1(nums1_connect0),.o_nums2(nums2_connect0),.o_nums3(nums3_connect0));

wire [6:0]segment_display_connect1;
wire [3:0]AN_connect1;
wire [9:0]nums0_connect1,nums1_connect1,nums2_connect1,nums3_connect1;
digital_segment ins1(
.nums(nums),
.num0(0),.num1(0),.num2(0),.num3(0),
.backspace(backspace),
.reset(reset),
.reset_stable((stable==4'b1000)&&(stable_record!=4'b1000)),
.clk_400hz(clk_400hz),
.o_segment_display(segment_display_connect1),
.o_AN(AN_connect1),
.o_nums0(nums0_connect1),.o_nums1(nums1_connect1),.o_nums2(nums2_connect1),.o_nums3(nums3_connect1));







always@(posedge clk_400hz)begin
    confirm_record<=confirm;
    stable_record<=stable;
 case(stable)

    4'b0001:begin              //正在输入密码状态
      AN<=AN_connect0;
      segment_display<=segment_display_connect0;
      nums0<=nums0_connect0;nums1<=nums1_connect0;nums2<=nums2_connect0;nums3<=nums3_connect0;
      if(confirm&&!confirm_record)begin
        if((nums0==key0)&&(nums1==key1)&&(nums2==key2)&&(nums3==key3))begin
          stable<=4'b0010;times<=0;
        end  else begin
           if(times==2)begin
            stable<=4'b0100;times<=0;
           end else 
           times<=times+1;
           alarm<=1;
        end
      end
      if(alarm==1)begin
        counter0<=counter0+1;
        if(counter0==400)begin
          alarm<=0;counter0<=0;
        end
      end
      if(administrate)begin stable=4'b1000;end
      if ((nums0!=nums0_connect0)||(nums1!=nums1_connect0)||(nums2!=nums2_connect0)||(nums3!=nums3_connect0)) begin
        counter <= 0;               // 如果有操作信号，计数器清零
        end else if (counter == 4000) begin
          stable_record<=0; 
          counter<=0;         // 20秒无操作,回归正在输入密码状态
        end else begin
          counter <= counter + 1;   // 计数器递增
        end
    end


   
    4'b0010:begin                   //开锁状态
   AN<=0;
   segment_display<=7'b0111111;
   led<=15'b111111111111111;
   if (operate) begin
        counter <= 0;               // 如果有操作信号，计数器清零
        end else if (counter == 8000) begin
          stable<=4'b0001; 
          counter<=0;
          led<=0;          // 20秒无操作,回归正在输入密码状态
        end else begin
          counter <= counter + 1;   // 计数器递增
        end
    if(administrate)begin 
        stable=4'b1000;
        led<=0;
        counter<=0;
        end
    if(confirm&&!confirm_record)begin
      stable<=4'b0001;
      counter<=0;
      led<=0;    

    end
    end


    4'b0100:begin              //报警状态状态
    alarm<=1;
    segment_display<=0;
    AN<=0;
    relieve_record<=relieve;
    if(relieve&&!relieve_record)begin
      stable<=4'b0001;
      alarm<=0;
    end 
    end
 

    4'b1000:begin               //管理员模式状态
      AN<=AN_connect1;
      segment_display<=segment_display_connect1;
      nums0<=nums0_connect1;nums1<=nums1_connect1;nums2<=nums2_connect1;nums3<=nums3_connect1;
      if(!administrate)begin 
        stable=4'b0001;
        key0<=nums0;
        key1<=nums1;
        key2<=nums2;
        key3<=nums3;
      end
    end
    endcase
end







endmodule
