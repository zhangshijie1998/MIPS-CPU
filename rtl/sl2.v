`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/28 23:44:26
// Design Name: 
// Module Name: sl2
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


module sl2 #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] a,
    output wire [WIDTH-1:0] y
);

assign y = {a[WIDTH-3:0], 2'b00};

endmodule
