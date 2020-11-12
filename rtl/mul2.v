`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/08 21:46:33
// Design Name: 
// Module Name: mul2
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


module mul2 (
    input  wire [15:0] a,
    input  wire [15:0] b,
    output wire [31:0] y
);

wire [7:0] a_l, a_h, b_l, b_h;
wire [15:0] r1, r2, r3, r4;

assign a_l = a[7:0];
assign a_h = a[15:8];
assign b_l = b[7:0];
assign b_h = b[15:8];
assign r1 = a_l * b_l;
assign r2 = a_l * b_h;
assign r3 = a_h * b_l;
assign r4 = a_h * b_h;
assign y = r1 + {r2, 8'b0} + {r3, 8'b0} + {r4, 16'b0};

endmodule
