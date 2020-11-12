`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/28 20:55:48
// Design Name: 
// Module Name: mux3
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


module mux3 #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2,
    input  wire       [1:0] sel,
    output wire [WIDTH-1:0] out
);

assign out = ({WIDTH{sel == 2'b00}} & in0)
           | ({WIDTH{sel == 2'b01}} & in1)
           | ({WIDTH{sel == 2'b10}} & in2);

endmodule
