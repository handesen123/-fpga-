`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/31 00:21:36
// Design Name: 
// Module Name: digital_segmet
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

module digital_segment( 
input [9:0]nums,
input [9:0]num0,num1,num2,num3,
input backspace,
input reset,
input reset_stable,
input clk_400hz,
output reg[6:0]o_segment_display,
output reg[3:0]o_AN,
output reg[9:0]o_nums0,o_nums1,o_nums2,o_nums3) ;

reg [6:0]segment_record0= 7'b0111111,segment_record1= 7'b0111111,segment_record2= 7'b0111111,segment_record3= 7'b0111111;   //分别用于记录各个数码管的数据
reg [3:0]nums_place=0;                                                        //用于定位数码管以及nums数据
reg [9:0]nums_prev=0;                                                         //用于与现在的nums比较从而接受来自板子上的输入数据
reg [9:0]nums0=0,nums1=0,nums2=0,nums3=0;                                           //用于记录各个nums数据
reg [1:0]scan;                                                              //用于循环亮起数码管
reg backspace_record;                                                       //退格键                                                         
reg once=0;                                                              //接受来自外部的信号一次
//开始情况的赋值


always@(*)begin
     o_nums0=nums0;
     o_nums1=nums1;
     o_nums2=nums2;
     o_nums3=nums3;
end

   integer i;integer j;
   always @(posedge clk_400hz) begin
    if(!once)begin
     for(j=0;j<10;j=j+1)begin
        nums0[j]=num0[j];nums1[j]=num1[j];nums2[j]=num2[j];nums3[j]=num3[j];
         nums_place<=nums_place+num0[j]+num1[j]+num2[j]+num3[j];
     end
     once<=1;
    end

    //退格
    backspace_record<=backspace;
        if((backspace&&!backspace_record))begin
            if(nums_place)begin
             nums_place<=nums_place-1;
             case(nums_place)
            4'b0001:begin
                nums0=0;
            end
            4'b0010:begin
                nums1=0;
            end
            4'b0011:begin
                nums2=0;
            end
            4'b0100:begin
                nums3=0;
            end
             endcase
            end
        end

    //复位
    if(reset||reset_stable)begin
        nums_place<=0;
        nums0=0;nums1=0;nums2=0;nums3=0;
    end

    if(nums_place==4'b0101)begin nums_place<=4'b0100;end


    //检测输入按钮输入的信号
    nums_prev<=nums;
    for(i=0;i<10;i=i+1)begin
            if (nums[i]&&!nums_prev[i]) begin
               nums_place<=nums_place+1;
            case(nums_place)
            4'b0000: begin nums0=nums;
            end
            4'b0001: begin nums1=nums;
            end
            4'b0010: begin nums2=nums;
            end
            4'b0011: begin nums3=nums;
            end
               endcase
            end
        end
    end

    always@(nums0,nums1,nums2,nums3)begin
            case(nums0)
            9'b0000000001: segment_record0 = 7'b1000000; // 0
            9'b0000000010: segment_record0 = 7'b1111001; // 1
            9'b0000000100: segment_record0 = 7'b0100100; // 2
            9'b0000001000: segment_record0 = 7'b0110000; // 3
            9'b0000010000: segment_record0 = 7'b0011001; // 4
            9'b0000100000: segment_record0 = 7'b0010010; // 5
            9'b0001000000: segment_record0 = 7'b0000010; // 6
            9'b0010000000: segment_record0 = 7'b1111000; // 7
            9'b0100000000: segment_record0 = 7'b0000000; // 8
            10'b1000000000:segment_record0 = 7'b0010000; // 9
            default: segment_record0 = 7'b0111111; // Blank
                endcase
    
            case(nums1)
            9'b0000000001: segment_record1 = 7'b1000000; // 0
            9'b0000000010: segment_record1= 7'b1111001; // 1
            9'b0000000100: segment_record1 = 7'b0100100; // 2
            9'b0000001000: segment_record1 = 7'b0110000; // 3
            9'b0000010000: segment_record1 = 7'b0011001; // 4
            9'b0000100000: segment_record1 = 7'b0010010; // 5
            9'b0001000000: segment_record1 = 7'b0000010; // 6
            9'b0010000000: segment_record1 = 7'b1111000; // 7
            9'b0100000000: segment_record1 = 7'b0000000; // 8
            10'b1000000000: segment_record1 = 7'b0010000; // 9
            default: segment_record1 = 7'b0111111; // Blank
                endcase
            case(nums2)
            9'b0000000001: segment_record2 = 7'b1000000; // 0
            9'b0000000010: segment_record2 = 7'b1111001; // 1
            9'b0000000100: segment_record2 = 7'b0100100; // 2
            9'b0000001000: segment_record2 = 7'b0110000; // 3
            9'b0000010000: segment_record2 = 7'b0011001; // 4
            9'b0000100000: segment_record2 = 7'b0010010; // 5
            9'b0001000000: segment_record2 = 7'b0000010; // 6
            9'b0010000000: segment_record2 = 7'b1111000; // 7
            9'b0100000000: segment_record2 = 7'b0000000; // 8
            10'b1000000000: segment_record2 = 7'b0010000; // 9
            default: segment_record2 = 7'b0111111; // Blank
                endcase
            case(nums3)
            9'b0000000001: segment_record3 = 7'b1000000; // 0
            9'b0000000010: segment_record3 = 7'b1111001; // 1
            9'b0000000100: segment_record3 = 7'b0100100; // 2
            9'b0000001000: segment_record3 = 7'b0110000; // 3
            9'b0000010000: segment_record3 = 7'b0011001; // 4
            9'b0000100000: segment_record3 = 7'b0010010; // 5
            9'b0001000000: segment_record3 = 7'b0000010; // 6
            9'b0010000000: segment_record3 = 7'b1111000; // 7
            9'b0100000000: segment_record3 = 7'b0000000; // 8
            10'b1000000000: segment_record3 = 7'b0010000; // 9
            default: segment_record3= 7'b0111111; // Blank
                endcase
               
 end

    always@(posedge clk_400hz)begin
        scan<=scan+1;
        o_AN=(4'b1111)^(4'b0001<<scan);
        case(o_AN)
        4'b1110: o_segment_display=segment_record0;
        4'b1101: o_segment_display=segment_record1;
        4'b1011: o_segment_display=segment_record2;
        4'b0111: o_segment_display=segment_record3;

        endcase
    end

endmodule
