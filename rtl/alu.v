`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/22 19:16:18
// Design Name: 
// Module Name: alu
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


module alu (
    input  wire [31:0] num1,
    input  wire [31:0] num2,//signlmm
    input  wire [ 4:0] sa,
    input  wire [ 3:0] op,
    output wire [31:0] result,
    output wire        zero,
    output wire        overflow
);

wire [31:0] sllout;
wire [31:0] srlout;
wire [31:0] product;

assign {overflow, result} = ({32{op == 4'b0000}} & (num1 & num2))   //and
                          | ({32{op == 4'b0001}} & (num1 | num2))   //or
                          | ({32{op == 4'b0010}} & (num1 + num2))   //add
                          | ({32{op == 4'b0011}} & product)         //mul
                          | ({32{op == 4'b0100}} & ~num1)           //not
                          | ({32{op == 4'b0101}} & 32'b0)           //clr
                          | ({32{op == 4'b0110}} & (num1 - num2))   //sub
                          | ({32{op == 4'b0111}} & (num1 < num2))   //slt
                          | ({32{op == 4'b1000}} & (num1 ^ num2))   //xor
                          | ({32{op == 4'b1001}} & {num2[15:0], 16'b0})//lui
                          | ({32{op == 4'b1010}} & sllout)          //sll
                          | ({32{op == 4'b1011}} & srlout)          //srl                                                 ;
                          | ({32{op == 4'b1100}} & (num1 ^ num2))   //
                          | ({32{op == 4'b1101}} & (num1 ^ num2))   //
                          | ({32{op == 4'b1110}} & (num1 ^ num2))   //
                          | ({32{op == 4'b1111}} & (num1 ^ num2));  //                         
assign zero = (result == 32'b0);

mul mul (
    .a (num1),
    .b (num2),
    .y (product)
);

sll sll (
    .in  (num2),
    .sa  (sa),
    .out (sllout)
);

srl srl (
    .in  (num2),
    .sa  (sa),
    .out (srlout)
);

endmodule
