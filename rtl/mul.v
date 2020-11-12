`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/08 19:22:54
// Design Name: 
// Module Name: mul
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


module mul (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] y
);

wire [15:0] a_l, a_h, b_l, b_h;
wire [31:0] r1;
wire [15:0] r2, r3;

assign a_l = a[15:0];
assign a_h = a[31:16];
assign b_l = b[15:0];
assign b_h = b[31:16];
assign y = r1 + {r2, 16'b0} + {r3, 16'b0};

mul2 mul2_1 (
    .a (a_l),
    .b (b_l),
    .y (r1)
);

mul2 mul2_2 (
    .a (a_l),
    .b (b_h),
    .y (r2)
);

mul2 mul2_3 (
    .a (a_h),
    .b (b_l),
    .y (r3)
);

endmodule
